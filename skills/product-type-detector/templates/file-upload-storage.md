# File Upload/Storage Architecture Depth

## File Upload Threat Model

### Attack Vectors & Mitigations

**1. Malware Upload**
- **Threat**: User uploads virus, ransomware, or malicious executable
- **Mitigation**: Virus scanning pipeline (see below)

**2. Path Traversal**
- **Threat**: Filename like `../../etc/passwd` overwrites system files
- **Mitigation**:
  ```typescript
  // ❌ BAD: Using client-provided filename
  const filePath = `/uploads/${req.body.filename}`

  // ✅ GOOD: Generate server-side filename
  const fileId = uuidv4()
  const extension = path.extname(req.file.originalname)
  const safeFilename = `${fileId}${extension}`
  const filePath = `/uploads/${safeFilename}`
  ```

**3. MIME Type Spoofing**
- **Threat**: Malicious `.exe` disguised as `.jpg` (MIME type mismatch)
- **Mitigation**: Validate actual file content, not just extension
  ```typescript
  import fileType from 'file-type'

  const buffer = await fs.readFile(uploadPath)
  const type = await fileType.fromBuffer(buffer)

  if (type.mime !== 'image/jpeg') {
    throw new Error('Invalid file type')
  }
  ```

**4. XXE (XML External Entity) Attack**
- **Threat**: Malicious SVG or XML file reads server files
- **Mitigation**: Sanitize SVG uploads, disable external entities
  ```typescript
  import DOMPurify from 'isomorphic-dompurify'

  const sanitized = DOMPurify.sanitize(svgContent, {
    USE_PROFILES: { svg: true }
  })
  ```

**5. File Size Bomb (Zip Bomb)**
- **Threat**: 10MB zip expands to 10GB, crashes server
- **Mitigation**: Enforce decompressed size limits
  ```typescript
  const maxUncompressedSize = 100 * 1024 * 1024  // 100MB
  let totalSize = 0

  zip.on('entry', (entry) => {
    totalSize += entry.uncompressedSize
    if (totalSize > maxUncompressedSize) {
      throw new Error('Decompressed size exceeds limit')
    }
  })
  ```

**6. CSRF (Cross-Site Request Forgery)**
- **Threat**: Malicious site uploads file on user's behalf
- **Mitigation**: Require CSRF token in upload requests
  ```typescript
  app.post('/upload', csrfProtection, upload.single('file'), ...)
  ```

**7. Unrestricted File Upload**
- **Threat**: Uploading `.php`, `.jsp` files to execute code on server
- **Mitigation**: Whitelist allowed extensions
  ```typescript
  const ALLOWED_EXTENSIONS = ['.jpg', '.png', '.pdf', '.docx']

  if (!ALLOWED_EXTENSIONS.includes(extension)) {
    throw new Error(`File type ${extension} not allowed`)
  }
  ```

---

## Virus Scanning Pipeline

### Architecture: S3 Quarantine → Scan → Production

```
User uploads file
  ↓
1. Upload to S3 quarantine bucket (uploads-quarantine/)
  ↓
2. S3 triggers Lambda on new object
  ↓
3. Lambda runs ClamAV scan
  ↓
4a. Clean → Move to production bucket (uploads/)
4b. Infected → Delete from quarantine, log incident
  ↓
5. Update database: file.status = 'clean' or 'infected'
```

### Implementation

**Step 1: Upload to Quarantine**
```typescript
app.post('/upload', upload.single('file'), async (req, res) => {
  const fileId = uuidv4()
  const extension = path.extname(req.file.originalname)
  const key = `quarantine/${fileId}${extension}`

  await s3.upload({
    Bucket: 'myapp-uploads',
    Key: key,
    Body: req.file.buffer
  }).promise()

  // Create database record
  await db.query(
    'INSERT INTO files (id, filename, status, s3_key) VALUES ($1, $2, $3, $4)',
    [fileId, req.file.originalname, 'scanning', key]
  )

  res.json({ fileId, status: 'scanning' })
})
```

**Step 2: Lambda Scans with ClamAV**
```typescript
// Lambda function triggered by S3 put event
import { S3, Lambda } from 'aws-sdk'
import { execSync } from 'child_process'

export const handler = async (event) => {
  const bucket = event.Records[0].s3.bucket.name
  const key = event.Records[0].s3.object.key  // quarantine/uuid.pdf

  // Download file
  const file = await s3.getObject({ Bucket: bucket, Key: key }).promise()
  const tempPath = `/tmp/${path.basename(key)}`
  await fs.writeFile(tempPath, file.Body)

  // Run ClamAV scan
  try {
    execSync(`clamscan ${tempPath}`)
    // Clean file

    // Move to production bucket
    const newKey = key.replace('quarantine/', 'files/')
    await s3.copyObject({
      Bucket: bucket,
      CopySource: `${bucket}/${key}`,
      Key: newKey
    }).promise()

    // Delete from quarantine
    await s3.deleteObject({ Bucket: bucket, Key: key }).promise()

    // Update database
    await db.query(
      'UPDATE files SET status = $1, s3_key = $2 WHERE s3_key = $3',
      ['clean', newKey, key]
    )

  } catch (err) {
    // Infected file
    await s3.deleteObject({ Bucket: bucket, Key: key }).promise()
    await db.query(
      'UPDATE files SET status = $1 WHERE s3_key = $2',
      ['infected', key]
    )

    // Alert admin
    await sns.publish({
      TopicArn: 'arn:aws:sns:us-east-1:123456:security-alerts',
      Message: `Infected file detected: ${key}`
    }).promise()
  }
}
```

**Step 3: Client Polls for Scan Result**
```typescript
app.get('/files/:id/status', async (req, res) => {
  const file = await db.query(
    'SELECT status FROM files WHERE id = $1',
    [req.params.id]
  )

  res.json({ status: file.status })  // scanning, clean, infected
})
```

**Alternative: Paid Service (Recommended for Simplicity)**
- **VirusTotal API**: $500/month for 10K scans
- **MetaDefender Cloud**: $200/month for 5K scans
- **Pros**: No ClamAV maintenance, better detection rates
- **Cons**: Cost, third-party dependency

---

## Image Optimization

### Automatic Resizing & Format Conversion

**On Upload, Generate Multiple Sizes**:
```typescript
import sharp from 'sharp'

app.post('/upload/image', upload.single('image'), async (req, res) => {
  const fileId = uuidv4()
  const buffer = req.file.buffer

  // Generate sizes: thumbnail (150px), small (400px), medium (800px), original
  const sizes = [
    { name: 'thumbnail', width: 150 },
    { name: 'small', width: 400 },
    { name: 'medium', width: 800 }
  ]

  const uploads = sizes.map(async ({ name, width }) => {
    const resized = await sharp(buffer)
      .resize(width)
      .webp({ quality: 80 })  // Convert to WebP (smaller than JPEG)
      .toBuffer()

    return s3.upload({
      Bucket: 'myapp-uploads',
      Key: `images/${fileId}-${name}.webp`,
      Body: resized,
      ContentType: 'image/webp'
    }).promise()
  })

  // Upload original
  uploads.push(
    s3.upload({
      Bucket: 'myapp-uploads',
      Key: `images/${fileId}-original.${ext}`,
      Body: buffer
    }).promise()
  )

  await Promise.all(uploads)

  res.json({
    fileId,
    urls: {
      thumbnail: `https://cdn.myapp.com/images/${fileId}-thumbnail.webp`,
      small: `https://cdn.myapp.com/images/${fileId}-small.webp`,
      medium: `https://cdn.myapp.com/images/${fileId}-medium.webp`,
      original: `https://cdn.myapp.com/images/${fileId}-original.${ext}`
    }
  })
})
```

**Why WebP?**
- 25-35% smaller than JPEG at same quality
- Supported in all modern browsers
- Fallback to JPEG for old browsers

**Background Processing (for Large Images)**:
```typescript
// Upload original immediately
await s3.upload({ Key: `originals/${fileId}`, Body: buffer })

// Queue background job to generate sizes
await queue.add('resize-image', { fileId })

// Worker processes job
worker.process('resize-image', async (job) => {
  const { fileId } = job.data
  const original = await s3.getObject({ Key: `originals/${fileId}` })
  // Generate sizes...
})
```

---

## Secure Download URLs

### Signed URLs with Expiration

**Generate Time-Limited Download URL**:
```typescript
app.get('/files/:id/download', async (req, res) => {
  const file = await db.query(
    'SELECT * FROM files WHERE id = $1 AND tenant_id = $2',
    [req.params.id, req.tenantId]  // ⚠️ Enforce tenant isolation
  )

  if (!file) return res.status(404).send('Not found')

  // Generate signed URL (expires in 1 hour)
  const url = s3.getSignedUrl('getObject', {
    Bucket: 'myapp-uploads',
    Key: file.s3_key,
    Expires: 3600  // 1 hour
  })

  res.json({ url })
})
```

**Why Signed URLs?**
- ✅ S3 bucket can be private (not public)
- ✅ URL expires automatically (no permanent links)
- ✅ Can't be shared beyond expiration
- ✅ Rate limiting per user (generate URL on demand)

**Alternative: Proxy Through Backend**
```typescript
app.get('/files/:id/download', async (req, res) => {
  const file = await db.query('SELECT * FROM files WHERE id = $1', [req.params.id])

  const s3Stream = s3.getObject({
    Bucket: 'myapp-uploads',
    Key: file.s3_key
  }).createReadStream()

  res.setHeader('Content-Disposition', `attachment; filename="${file.filename}"`)
  s3Stream.pipe(res)
})
```

**Pros**: More control (rate limiting, logging)
**Cons**: Backend bandwidth consumed (costly at scale)

**Recommendation**:
- **Small files** (<10MB): Proxy through backend (easier logging)
- **Large files** (>10MB): Signed URLs (save bandwidth)

---

## Upload Size Limits

### Enforce Limits at Multiple Layers

**1. Client-Side Check (UX)**
```javascript
document.querySelector('#file-input').addEventListener('change', (e) => {
  const file = e.target.files[0]
  const maxSize = 50 * 1024 * 1024  // 50MB

  if (file.size > maxSize) {
    alert('File size exceeds 50MB limit')
    e.target.value = ''  // Clear input
  }
})
```

**2. Multer Middleware (Server)**
```typescript
const upload = multer({
  limits: { fileSize: 50 * 1024 * 1024 },  // 50MB
  fileFilter: (req, file, cb) => {
    const allowedTypes = ['image/jpeg', 'image/png', 'application/pdf']
    if (!allowedTypes.includes(file.mimetype)) {
      return cb(new Error('Invalid file type'))
    }
    cb(null, true)
  }
})
```

**3. CloudFront/ALB Limit (Infrastructure)**
```yaml
# AWS ALB
MaxRequestSize: 50MB
```

**Why Multiple Layers?**
- Client check: Fast feedback (no upload wasted)
- Server check: Enforcement (client check can be bypassed)
- Infra check: Defense in depth (prevent DDoS via huge uploads)

---

## Chunked Upload (For Large Files)

### Multipart Upload to S3

**For files >100MB, use chunked uploads**:

**Client-Side (Browser)**
```javascript
const chunkSize = 5 * 1024 * 1024  // 5MB chunks
const chunks = Math.ceil(file.size / chunkSize)

// 1. Initiate multipart upload
const { uploadId } = await fetch('/upload/initiate', {
  method: 'POST',
  body: JSON.stringify({ filename: file.name, size: file.size })
}).then(r => r.json())

// 2. Upload each chunk
const parts = []
for (let i = 0; i < chunks; i++) {
  const start = i * chunkSize
  const end = Math.min(start + chunkSize, file.size)
  const chunk = file.slice(start, end)

  const { presignedUrl } = await fetch(`/upload/${uploadId}/part/${i + 1}`)
    .then(r => r.json())

  const response = await fetch(presignedUrl, {
    method: 'PUT',
    body: chunk
  })

  parts.push({
    PartNumber: i + 1,
    ETag: response.headers.get('ETag')
  })
}

// 3. Complete upload
await fetch(`/upload/${uploadId}/complete`, {
  method: 'POST',
  body: JSON.stringify({ parts })
})
```

**Backend**
```typescript
app.post('/upload/initiate', async (req, res) => {
  const { filename, size } = req.body
  const key = `uploads/${uuidv4()}/${filename}`

  const { UploadId } = await s3.createMultipartUpload({
    Bucket: 'myapp-uploads',
    Key: key
  }).promise()

  res.json({ uploadId: UploadId, key })
})

app.get('/upload/:uploadId/part/:partNumber', async (req, res) => {
  const url = s3.getSignedUrl('uploadPart', {
    Bucket: 'myapp-uploads',
    Key: req.query.key,
    UploadId: req.params.uploadId,
    PartNumber: req.params.partNumber,
    Expires: 3600
  })

  res.json({ presignedUrl: url })
})

app.post('/upload/:uploadId/complete', async (req, res) => {
  await s3.completeMultipartUpload({
    Bucket: 'myapp-uploads',
    Key: req.query.key,
    UploadId: req.params.uploadId,
    MultipartUpload: { Parts: req.body.parts }
  }).promise()

  res.json({ success: true })
})
```

**Benefits**:
- ✅ Resume uploads if connection drops
- ✅ Parallel chunk uploads (faster)
- ✅ Works for files up to 5TB

---

## CDN for Fast Delivery

### CloudFront in Front of S3

**Setup**:
```
CloudFront distribution → S3 bucket (origin)
```

**Benefits**:
- ✅ Edge caching (files served from nearest location)
- ✅ Reduces S3 GET costs (CloudFront caches)
- ✅ Faster downloads (CDN vs direct S3)

**Cost**:
- **S3 GET**: $0.0004 per 1000 requests
- **CloudFront**: $0.085 per GB (first 10TB/month)
- **Savings**: If 1M downloads of 1MB file → $340 with CloudFront vs $400 direct S3

**Cache Headers**:
```typescript
await s3.upload({
  Bucket: 'myapp-uploads',
  Key: file.key,
  Body: file.buffer,
  CacheControl: 'public, max-age=31536000'  // Cache for 1 year
}).promise()
```

---

## Database Schema

```sql
CREATE TABLE files (
  id UUID PRIMARY KEY,
  tenant_id UUID NOT NULL,  -- For multi-tenant
  user_id UUID NOT NULL,
  filename TEXT NOT NULL,
  size_bytes BIGINT NOT NULL,
  mime_type TEXT NOT NULL,
  s3_key TEXT NOT NULL,
  status TEXT NOT NULL,  -- scanning, clean, infected
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  INDEX idx_files_tenant (tenant_id),
  INDEX idx_files_user (user_id)
);
```

---

## Security Checklist

- [ ] Virus scanning for all uploads (ClamAV or paid service)
- [ ] Validate MIME type with actual file content (not just extension)
- [ ] Generate server-side filenames (prevent path traversal)
- [ ] Whitelist allowed file extensions
- [ ] Enforce file size limits (client + server + infra)
- [ ] Sanitize SVG/XML uploads (prevent XXE)
- [ ] Use signed URLs (private S3 bucket)
- [ ] CSRF protection on upload endpoints
- [ ] Tenant-scoped file storage (S3 prefix per tenant)
- [ ] Rate limit uploads per user
- [ ] Chunked uploads for large files (>100MB)
- [ ] CDN for fast delivery (CloudFront)

---

## Cost Implications

**Storage**:
- **S3**: $0.023 per GB/month (first 50TB)
- **1TB of files**: $23/month

**Data Transfer**:
- **S3 → Internet**: $0.09 per GB
- **CloudFront**: $0.085 per GB (first 10TB/month)
- **10TB downloads**: $850/month (with CloudFront) vs $900 (direct S3)

**Virus Scanning**:
- **ClamAV on Lambda**: ~$50/month (Lambda + S3 events)
- **VirusTotal API**: $500/month for 10K scans

**Image Optimization**:
- **Lambda + Sharp**: ~$10/month for 10K images
