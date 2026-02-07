# Content Platform Architecture Depth

## Publishing Workflow

### Draft → Review → Published State Machine

```
draft (author editing)
  ↓
submitted (ready for review)
  ↓
in_review (editor reviewing)
  ↓
approved (editor approved) OR rejected (back to draft)
  ↓
scheduled (publish at future time) OR published (live now)
  ↓
archived (no longer visible)
```

**Database Schema**:
```sql
CREATE TABLE posts (
  id UUID PRIMARY KEY,
  author_id UUID NOT NULL,
  title TEXT NOT NULL,
  slug TEXT UNIQUE NOT NULL,
  content JSONB NOT NULL,  -- Structured content (see below)
  excerpt TEXT,
  status TEXT NOT NULL CHECK (status IN ('draft', 'submitted', 'in_review', 'approved', 'rejected', 'scheduled', 'published', 'archived')),
  published_at TIMESTAMPTZ,
  scheduled_for TIMESTAMPTZ,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE post_revisions (
  id UUID PRIMARY KEY,
  post_id UUID NOT NULL,
  content JSONB NOT NULL,
  changed_by UUID NOT NULL,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);
```

**Auto-Publish Scheduled Posts** (cron job every minute):
```typescript
cron.schedule('* * * * *', async () => {
  await db.query(
    `UPDATE posts
     SET status = 'published', published_at = NOW()
     WHERE status = 'scheduled' AND scheduled_for <= NOW()`
  )
})
```

---

## SEO Architecture

### Meta Tags & Open Graph

**Server-Side Rendering for SEO**:
```typescript
app.get('/blog/:slug', async (req, res) => {
  const post = await db.query('SELECT * FROM posts WHERE slug = $1 AND status = $2', [req.params.slug, 'published'])

  const html = `
    <!DOCTYPE html>
    <html>
      <head>
        <title>${post.title} | Blog</title>
        <meta name="description" content="${post.excerpt}" />

        <!-- Open Graph (Facebook, LinkedIn) -->
        <meta property="og:type" content="article" />
        <meta property="og:title" content="${post.title}" />
        <meta property="og:description" content="${post.excerpt}" />
        <meta property="og:image" content="${post.featured_image_url}" />
        <meta property="og:url" content="https://example.com/blog/${post.slug}" />

        <!-- Twitter Card -->
        <meta name="twitter:card" content="summary_large_image" />
        <meta name="twitter:title" content="${post.title}" />
        <meta name="twitter:description" content="${post.excerpt}" />
        <meta name="twitter:image" content="${post.featured_image_url}" />

        <!-- Schema.org (Google) -->
        <script type="application/ld+json">
        {
          "@context": "https://schema.org",
          "@type": "BlogPosting",
          "headline": "${post.title}",
          "image": "${post.featured_image_url}",
          "datePublished": "${post.published_at}",
          "dateModified": "${post.updated_at}",
          "author": {
            "@type": "Person",
            "name": "${post.author_name}"
          }
        }
        </script>
      </head>
      <body>
        ${renderPost(post)}
      </body>
    </html>
  `

  res.send(html)
})
```

---

### Sitemap Generation

**Automatic Sitemap for SEO**:
```typescript
app.get('/sitemap.xml', async (req, res) => {
  const posts = await db.query(
    'SELECT slug, updated_at FROM posts WHERE status = $1 ORDER BY updated_at DESC',
    ['published']
  )

  const xml = `<?xml version="1.0" encoding="UTF-8"?>
<urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9">
  ${posts.map(post => `
  <url>
    <loc>https://example.com/blog/${post.slug}</loc>
    <lastmod>${post.updated_at.toISOString()}</lastmod>
    <changefreq>weekly</changefreq>
    <priority>0.8</priority>
  </url>
  `).join('')}
</urlset>`

  res.header('Content-Type', 'application/xml')
  res.send(xml)
})
```

**Submit to Search Engines**:
```typescript
// Ping Google when new post published
await fetch(`https://www.google.com/ping?sitemap=https://example.com/sitemap.xml`)
```

---

## Rich Text Storage

### Structured Content vs HTML

**Option 1: Markdown** (Simple, recommended for blogs)
```sql
ALTER TABLE posts ADD COLUMN content_markdown TEXT;
```

**Rendering**:
```typescript
import marked from 'marked'
import DOMPurify from 'isomorphic-dompurify'

const html = DOMPurify.sanitize(marked.parse(post.content_markdown))
```

**Pros**:
- ✅ Simple to store and edit
- ✅ Version control friendly (plain text)
- ✅ Fast rendering

**Cons**:
- ❌ Limited formatting (no custom blocks)

---

**Option 2: Structured JSON (Editor.js, Lexical)** (Recommended for rich content)
```json
{
  "type": "doc",
  "content": [
    {
      "type": "heading",
      "attrs": { "level": 1 },
      "content": [{ "type": "text", "text": "My Article" }]
    },
    {
      "type": "paragraph",
      "content": [{ "type": "text", "text": "First paragraph..." }]
    },
    {
      "type": "image",
      "attrs": {
        "src": "https://cdn.example.com/image.jpg",
        "alt": "Description"
      }
    },
    {
      "type": "codeBlock",
      "attrs": { "language": "javascript" },
      "content": [{ "type": "text", "text": "const x = 1;" }]
    }
  ]
}
```

**Pros**:
- ✅ Rich formatting (images, embeds, code blocks)
- ✅ Custom blocks (callouts, tables, etc.)
- ✅ Safe (no arbitrary HTML)

**Cons**:
- ❌ More complex to render
- ❌ Requires frontend editor library

**Rendering**:
```typescript
function renderContent(doc) {
  return doc.content.map(block => {
    if (block.type === 'heading') {
      return `<h${block.attrs.level}>${block.content[0].text}</h${block.attrs.level}>`
    }
    if (block.type === 'paragraph') {
      return `<p>${block.content.map(c => c.text).join('')}</p>`
    }
    if (block.type === 'image') {
      return `<img src="${block.attrs.src}" alt="${block.attrs.alt}" />`
    }
  }).join('\n')
}
```

---

**Option 3: HTML** (⚠️ Security Risk)
- **Only if**: User input is from trusted admins only
- **Sanitize**: Always use DOMPurify
- **Never**: Store unsanitized user HTML (XSS vulnerability)

---

## Content Moderation

### Spam Detection

**Akismet Integration**:
```typescript
import Akismet from 'akismet-api'

const akismet = new Akismet({
  key: process.env.AKISMET_KEY,
  blog: 'https://example.com'
})

app.post('/posts', async (req, res) => {
  const isSpam = await akismet.checkSpam({
    user_ip: req.ip,
    user_agent: req.headers['user-agent'],
    comment_content: req.body.content,
    comment_author: req.user.name
  })

  if (isSpam) {
    return res.status(400).json({ error: 'Content flagged as spam' })
  }

  // Create post...
})
```

**Cost**: $5/month for 1K checks

---

### Profanity Filter

```typescript
import Filter from 'bad-words'

const filter = new Filter()

if (filter.isProfane(content)) {
  throw new Error('Content contains profanity')
}

// Auto-clean (replace with asterisks)
const cleaned = filter.clean(content)
```

---

### User-Generated Content Moderation Queue

**Flagging System**:
```sql
CREATE TABLE content_flags (
  id UUID PRIMARY KEY,
  post_id UUID NOT NULL,
  flagged_by UUID NOT NULL,
  reason TEXT NOT NULL,  -- spam, abuse, copyright
  status TEXT NOT NULL DEFAULT 'pending',  -- pending, reviewed, actioned
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);
```

**Moderator Review**:
```typescript
app.get('/admin/flagged-posts', adminOnly, async (req, res) => {
  const flagged = await db.query(`
    SELECT posts.*, COUNT(content_flags.id) as flag_count
    FROM posts
    JOIN content_flags ON content_flags.post_id = posts.id
    WHERE content_flags.status = 'pending'
    GROUP BY posts.id
    ORDER BY flag_count DESC
  `)

  res.json(flagged)
})
```

---

## Analytics Integration

### Page View Tracking

**Option 1: PostHog (Privacy-Friendly)**
```html
<script>
  !function(t,e){var o,n,p,r;e.__SV||(window.posthog=e,e._i=[],e.init=function(i,s,a){...})}(window,window.posthog||[]);
  posthog.init('YOUR_API_KEY', {api_host:'https://app.posthog.com'})
</script>

<script>
  // Track page view
  posthog.capture('$pageview', {
    post_id: '${post.id}',
    post_slug: '${post.slug}'
  })
</script>
```

**Cost**: $0 for <1M events/month

---

**Option 2: Server-Side Tracking**
```typescript
app.get('/blog/:slug', async (req, res) => {
  const post = await db.query('SELECT * FROM posts WHERE slug = $1', [req.params.slug])

  // Increment view count
  await db.query('UPDATE posts SET view_count = view_count + 1 WHERE id = $1', [post.id])

  // Log detailed analytics
  await db.query(
    'INSERT INTO post_views (post_id, ip_address, user_agent, referrer) VALUES ($1, $2, $3, $4)',
    [post.id, req.ip, req.headers['user-agent'], req.headers['referer']]
  )

  res.send(renderPost(post))
})
```

**Pros**: Full control, no third-party
**Cons**: DB writes on every page view (use Redis counter instead)

---

## Slug Generation

### URL-Friendly Slugs

```typescript
import slugify from 'slugify'

function generateSlug(title: string): string {
  let slug = slugify(title, { lower: true, strict: true })

  // Handle duplicates
  let unique = slug
  let counter = 1
  while (await db.query('SELECT 1 FROM posts WHERE slug = $1', [unique])) {
    unique = `${slug}-${counter++}`
  }

  return unique
}

// Example: "My Awesome Post!" → "my-awesome-post"
//          "My Awesome Post!" (duplicate) → "my-awesome-post-1"
```

---

## Comments System

### Database Schema

```sql
CREATE TABLE comments (
  id UUID PRIMARY KEY,
  post_id UUID NOT NULL,
  parent_id UUID,  -- For nested replies
  author_id UUID NOT NULL,
  content TEXT NOT NULL,
  status TEXT NOT NULL DEFAULT 'pending',  -- pending, approved, spam, deleted
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_comments_post ON comments(post_id, status, created_at DESC);
```

**Nested Comments (Threaded Replies)**:
```typescript
app.get('/posts/:id/comments', async (req, res) => {
  const comments = await db.query(`
    WITH RECURSIVE comment_tree AS (
      -- Top-level comments
      SELECT *, 0 as depth
      FROM comments
      WHERE post_id = $1 AND parent_id IS NULL AND status = 'approved'

      UNION ALL

      -- Replies
      SELECT c.*, ct.depth + 1
      FROM comments c
      JOIN comment_tree ct ON c.parent_id = ct.id
      WHERE c.status = 'approved'
    )
    SELECT * FROM comment_tree ORDER BY depth, created_at ASC
  `, [req.params.id])

  res.json(buildCommentTree(comments))
})
```

---

## RSS Feed

```typescript
app.get('/rss.xml', async (req, res) => {
  const posts = await db.query(`
    SELECT * FROM posts
    WHERE status = 'published'
    ORDER BY published_at DESC
    LIMIT 20
  `)

  const xml = `<?xml version="1.0" encoding="UTF-8"?>
<rss version="2.0">
  <channel>
    <title>My Blog</title>
    <link>https://example.com</link>
    <description>Latest posts</description>
    ${posts.map(post => `
    <item>
      <title>${post.title}</title>
      <link>https://example.com/blog/${post.slug}</link>
      <description>${post.excerpt}</description>
      <pubDate>${post.published_at.toUTCString()}</pubDate>
      <guid>https://example.com/blog/${post.slug}</guid>
    </item>
    `).join('')}
  </channel>
</rss>`

  res.header('Content-Type', 'application/xml')
  res.send(xml)
})
```

---

## Security Checklist

- [ ] HTML sanitization (DOMPurify for user content)
- [ ] XSS prevention (never render unsanitized HTML)
- [ ] Spam detection (Akismet or similar)
- [ ] Profanity filter (optional, for public platforms)
- [ ] Rate limit post creation (prevent spam)
- [ ] CSRF protection on forms
- [ ] Content moderation queue for flagged posts
- [ ] Secure slug generation (no special chars, handle duplicates)

---

## Cost Implications

**Akismet (Spam Detection)**:
- $5/month for 1K checks

**PostHog (Analytics)**:
- Free for <1M events/month
- $450/month for 10M events

**CDN for Images** (Cloudflare):
- Free for <10TB/month bandwidth

**Email (Newsletters)**:
- Resend: $20/month for 50K emails
- SendGrid: $15/month for 40K emails
