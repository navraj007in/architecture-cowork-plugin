---
name: Compliance & Security Standards
description: Compliance frameworks (SOC2, HIPAA, GDPR, PCI DSS) with control mappings and implementation guidance
---

# Compliance & Security Standards Skill

Framework-specific compliance guidance for regulated industries: SOC2 Type II, HIPAA, GDPR, and PCI DSS. Includes control mappings, audit logging patterns, data residency rules, and scope reduction strategies.

## Overview

Compliance is a multi-layer problem: legal obligations (what must be done), technical controls (how to implement), and operational processes (who does it). This skill focuses on technical controls and their code-level implementation.

## Framework Mapping

| Framework | Industry | Focus | Audit Frequency | Scope |
|-----------|----------|-------|-----------------|-------|
| **SOC2 Type II** | Cloud/SaaS | Security, availability, confidentiality, integrity, privacy | Annual + 6 months snapshot | All services |
| **HIPAA** | Healthcare | Protected Health Information (PHI) protection | Triennial + event-driven | All systems handling PHI |
| **GDPR** | EU/International | Personal Data protection and rights | Ongoing (data subject requests) | EU users + data |
| **PCI DSS** | Payment | Payment Card Industry data | Annual + quarterly scans | Systems handling card data |

## SOC2 Type II

### Security (CC — Common Criteria)

| Control | Implementation | Code Pattern |
|---------|----------------|--------------|
| **CC6.1** Infrastructure monitoring | Prometheus metrics on all services | `GET /metrics` endpoint emits errors, latency, resource usage |
| **CC6.2** Deployment access control | GitHub branch protection + required code review | Enforce 2 approvals before merge to main |
| **CC6.3** Change management | All changes logged with who, when, what | Git commit history + CI/CD logs |
| **CC6.4** Backup & recovery | Automated daily backups with RTO/RPO | `pg_dump` schedule + S3 replication |
| **CC7.2** Encryption at rest | Database encryption (AWS KMS, PostgreSQL pgcrypto) | `CREATE EXTENSION pgcrypto;` + field-level encryption |
| **CC7.3** Encryption in transit | TLS 1.2+ for all network traffic | `https://` only, no cleartext HTTP |
| **CC7.4** Cryptographic key management | Key rotation, secure storage | AWS Secrets Manager or HashiCorp Vault |

### Availability (A — Availability and Resilience)

| Control | Implementation | Code Pattern |
|---------|----------------|--------------|
| **A1.1** Availability SLOs | 99.5% uptime target | Monitor error budget daily |
| **A1.2** Incident response | Documented runbooks, on-call escalation | Slack automation + PagerDuty |
| **A2.1** Capacity planning | Monitor and right-size resources | Auto-scaling rules based on CPU/memory |

### Confidentiality (C — Confidentiality)

| Control | Implementation | Code Pattern |
|---------|----------------|--------------|
| **C1.1** Data classification | Tag all data fields with sensitivity (public/internal/confidential) | Schema comments: `-- @sensitive: true` |
| **C1.2** Access controls | Role-based access (RBAC) with least privilege | Middleware: `@RequireRole('admin')` |
| **C1.3** Audit logging | Log all data access | `SELECT * FROM users` logs: who, when, what |

### Integrity (I — Integrity)

| Control | Implementation | Code Pattern |
|---------|----------------|--------------|
| **I1.1** Data validation | Input validation on all boundaries | Zod/FluentValidation schemas |
| **I2.1** Change detection | Checksums and signatures for critical data | Hash on INSERT/UPDATE, verify on SELECT |

---

## HIPAA (Health Insurance Portability and Accountability Act)

### Key Definitions

- **PHI (Protected Health Information):** Any health information linked to an individual (medical record, payment info, biometric data)
- **HIPAA Minimum Necessary:** Limit collection, use, and sharing of PHI to what is required
- **BAA (Business Associate Agreement):** Required if a third party processes PHI on your behalf

### Technical Safeguards (Required)

| Safeguard | Implementation |
|-----------|----------------|
| **Access Controls** | User authentication (MFA), authorization (RBAC), PHI field-level encryption |
| **Audit Controls** | Immutable audit log: who accessed which PHI, when, from where |
| **Integrity Controls** | Data checksums, tamper detection, digital signatures for PHI |
| **Transmission Security** | TLS 1.2+ for all PHI transmission; VPN for remote access |

### Code-Level Implementation

**Patient data segregation:**
```typescript
// Mark all PHI fields explicitly
interface Patient {
  id: string; // Not PHI
  email: string; // PHI: emails can identify
  ssn: string; // PHI: highly sensitive
  medicalRecord: string; // PHI: diagnosis, treatment
  createdAt: Date; // Not PHI
}

// Enforce access control on PHI fields
@RequireRole('healthcare-provider')
app.get('/patients/:id', (req, res) => {
  const patient = await db.patient.findUnique({
    where: { id: req.params.id }
  });
  
  // Log PHI access for audit
  auditLog.record({
    action: 'PHI_READ',
    user_id: req.user.id,
    patient_id: patient.id,
    timestamp: new Date(),
    ip_address: req.ip
  });
  
  res.json(patient);
});
```

**Encryption:**
```typescript
// Encrypt sensitive fields at rest
const encryptedSSN = encrypt(patient.ssn, process.env.ENCRYPTION_KEY);
await db.patient.update({
  where: { id: patient.id },
  data: { ssn: encryptedSSN }
});
```

**Audit logging (immutable):**
```typescript
// Append-only audit log (never update/delete)
interface AuditLog {
  id: string;
  action: 'PHI_READ' | 'PHI_CREATE' | 'PHI_UPDATE' | 'PHI_DELETE';
  user_id: string;
  patient_id: string;
  timestamp: Date; // Server time, not client
  ip_address: string;
  user_agent: string;
  phiFields: string[]; // Which fields were accessed
}

// Store in dedicated immutable table
await db.auditLog.create({ data: auditEntry });
```

---

## GDPR (General Data Protection Regulation)

### Key Principles

1. **Lawfulness, Fairness, Transparency** — Must have legal basis for processing personal data
2. **Purpose Limitation** — Can only use data for declared purpose
3. **Data Minimization** — Collect only what is necessary
4. **Accuracy** — Keep personal data accurate and up-to-date
5. **Storage Limitation** — Don't keep longer than necessary
6. **Integrity & Confidentiality** — Protect against unauthorized access
7. **Accountability** — Document why/how data is processed

### Data Rights (User-Facing Features)

| Right | Implementation | Timeline |
|-------|----------------|----------|
| **Right to Access** | `/api/users/{id}/export` endpoint returns all user data in machine-readable format | 30 days |
| **Right to Rectification** | `/api/users/{id}/data` PUT endpoint allows user to correct their data | Immediate |
| **Right to Erasure** ("Right to be Forgotten") | `/api/users/{id}` DELETE removes all personal data (GDPR Article 17) | 30 days |
| **Right to Restrict Processing** | User can request their data not be processed (e.g., marketing emails) | Immediate |
| **Right to Data Portability** | Export in standard format (JSON, CSV) for migration to another service | 30 days |
| **Right to Object** | Opt out of profiling, automated decision-making | Immediate |

### Code Implementation

**Data export (Right to Access):**
```typescript
app.get('/api/users/:id/export', @Authenticated, async (req, res) => {
  // Verify user is requesting their own data
  if (req.user.id !== req.params.id) throw new UnauthorizedError();
  
  const userData = await db.user.findUnique({
    where: { id: req.params.id },
    include: {
      orders: true,
      addresses: true,
      profile: true
    }
  });
  
  // Log data access for GDPR compliance
  auditLog.record({
    action: 'GDPR_DATA_EXPORT',
    user_id: req.user.id,
    timestamp: new Date()
  });
  
  // Return in machine-readable format
  res.json({
    user: userData,
    exportedAt: new Date().toISOString(),
    dataControllerContact: 'privacy@example.com'
  });
});
```

**Right to Erasure:**
```typescript
app.delete('/api/users/:id', @Authenticated, async (req, res) => {
  if (req.user.id !== req.params.id) throw new UnauthorizedError();
  
  const user = await db.user.findUnique({ where: { id: req.params.id } });
  
  // Log deletion request
  auditLog.record({
    action: 'GDPR_ERASURE_REQUEST',
    user_id: req.user.id,
    timestamp: new Date()
  });
  
  // Soft delete: mark as erased, but keep for audit trail
  await db.user.update({
    where: { id: req.params.id },
    data: {
      deletedAt: new Date(),
      email: '[ERASED]',
      firstName: '[ERASED]',
      lastName: '[ERASED]',
      // Clear all personal data
    }
  });
  
  res.sendStatus(204);
});
```

**Consent management:**
```typescript
interface UserConsent {
  user_id: string;
  marketing_emails: boolean; // Opt-in
  analytics: boolean; // Opt-in
  third_party_sharing: boolean; // Opt-in
  timestamp: Date;
  ip_address: string;
  user_agent: string;
}

// Always ask before collecting data
app.post('/api/users/{id}/consent', async (req, res) => {
  await db.userConsent.create({
    data: {
      user_id: req.user.id,
      marketing_emails: req.body.marketingEmails,
      analytics: req.body.analytics,
      timestamp: new Date(),
      ip_address: req.ip
    }
  });
  
  // Only send marketing emails if user consented
  if (consent.marketing_emails) {
    await sendMarketingEmail(user);
  }
});
```

**Data retention:**
```typescript
// Schedule job to delete data older than retention period
// GDPR principle: "Storage Limitation"
schedule.every().day.at('02:00').do(async () => {
  const thirtyDaysAgo = new Date(Date.now() - 30 * 24 * 60 * 60 * 1000);
  
  // Delete soft-deleted users after 30 days
  await db.user.deleteMany({
    where: {
      deletedAt: { lt: thirtyDaysAgo }
    }
  });
  
  // Delete old audit logs (keep for 1 year for compliance)
  const oneYearAgo = new Date(Date.now() - 365 * 24 * 60 * 60 * 1000);
  await db.auditLog.deleteMany({
    where: {
      timestamp: { lt: oneYearAgo }
    }
  });
});
```

---

## PCI DSS (Payment Card Industry Data Security Standard)

### Scope Reduction Strategy

**Golden Rule:** Don't store card data. Use a payment processor (Stripe, Square, PayPal) to tokenize and store; keep only the token.

### Minimal Implementation (Scope Reduced)

| Control | Implementation |
|---------|----------------|
| **No card storage** | All card data goes directly to Stripe; you store only token |
| **No PAN (Primary Account Number) in logs** | Never log or error-message card numbers |
| **TLS for all card transmissions** | HTTPS only; no cleartext HTTP |
| **Access control** | Only backend can request card tokens; frontend never sees raw data |

### Code Pattern

**Stripe Tokenization (Recommended):**
```typescript
// Frontend: Use Stripe Elements (handles PCI compliance)
const stripe = require('@stripe/stripe-js');
const card = elements.create('card');
card.mount('#card-element');

// When user submits form
const { token } = await stripe.createToken(card);
// Token is sent to backend, NOT card number
await fetch('/api/payment', {
  method: 'POST',
  body: JSON.stringify({ token: token.id })
});
```

**Backend: Process Token (Not Card Data):**
```typescript
const stripe = require('stripe')(process.env.STRIPE_SECRET_KEY);

app.post('/api/payment', async (req, res) => {
  // req.body.token is a Stripe token, not card data
  const charge = await stripe.charges.create({
    amount: 9999, // in cents
    currency: 'usd',
    source: req.body.token, // Token, not card
    metadata: {
      order_id: req.body.orderId,
      user_id: req.user.id
    }
  });
  
  // Log transaction (NO card data logged)
  auditLog.record({
    action: 'PAYMENT',
    user_id: req.user.id,
    amount: 9999,
    charge_id: charge.id,
    timestamp: new Date()
  });
  
  res.json({ success: true, charge_id: charge.id });
});
```

### What NOT to Do (PCI Violations)

```typescript
// ❌ DO NOT store card data
app.post('/api/payment', async (req, res) => {
  await db.payment.create({
    cardNumber: req.body.cardNumber, // ❌ VIOLATION
    cvv: req.body.cvv, // ❌ VIOLATION
    expiryDate: req.body.expiryDate // ❌ VIOLATION
  });
});

// ❌ DO NOT log card data
logger.info(`Payment for user ${userId} with card ${cardNumber}`); // ❌ VIOLATION

// ❌ DO NOT send card data over HTTP
app.post('http://api.example.com/payment', { cardNumber: '...' }); // ❌ VIOLATION (HTTP not HTTPS)
```

---

## Compliance Audit Checklist

### Pre-Audit Preparation

- [ ] Data classification complete (mark all fields as PII, PHI, payment data, etc.)
- [ ] Audit logging implemented (immutable, tamper-proof, all access logged)
- [ ] Encryption enabled (at rest: database; in transit: TLS 1.2+)
- [ ] Access control implemented (RBAC, MFA for admin, session management)
- [ ] Backup & recovery tested (RTO/RPO documented, restore tested)
- [ ] Incident response plan documented (runbooks, on-call escalation, notification procedures)
- [ ] Data retention policies defined (how long to keep what data)
- [ ] Vendor/third-party BAAs in place (if using cloud services)
- [ ] Vulnerability scanning automated (SAST, dependency scanning)
- [ ] Penetration testing scheduled (annual for most frameworks)

### Evidence Collection

For each control, prepare evidence:
- **Code:** GitHub links to implementation (e.g., encryption middleware)
- **Configuration:** Screenshots of security settings (e.g., TLS version, MFA)
- **Logs:** Sample audit logs showing access control in action
- **Policies:** Document data classification, retention, incident response
- **Test Results:** Vulnerability scans, penetration test reports

---

## Multi-Framework Compliance

### HIPAA + GDPR

Both require strong encryption, audit logging, and user data rights. Overlap on:
- Encryption at rest and in transit
- User right to access their data
- Audit trail of all access

**Difference:** HIPAA focuses on healthcare industry; GDPR applies to EU personal data globally.

### SOC2 + PCI DSS

SOC2 is a trust framework (controls and processes); PCI DSS is payment-specific.

**SOC2 covers:** Security, availability, confidentiality, integrity, privacy  
**PCI DSS covers:** Only payment card data

---

## Compliance Scoring

### Control Assessment Matrix

| Status | Definition | Action |
|--------|-----------|--------|
| **Implemented** | Control is coded, tested, documented | ✅ Ready for audit |
| **Partial** | Control exists but has gaps (e.g., encryption on some fields, not all) | ⚠️ Remediate gaps |
| **Missing** | Control not implemented | 🔴 Must implement before audit |
| **Not Applicable** | Control doesn't apply to your product | ℹ️ Document why (e.g., no payment processing → PCI not applicable) |

### Gap Scoring

**Critical (Must Fix Before Production):**
- No encryption in transit (HTTP instead of HTTPS)
- No authentication on sensitive endpoints
- Credentials hardcoded or in logs
- Direct database access from frontend

**High (Must Fix Before Audit):**
- Audit logging not comprehensive
- Data retention policy undefined
- Backup testing not documented
- No incident response plan

**Medium (Should Fix):**
- Some fields not encrypted at rest
- Rate limiting missing
- Monitoring gaps

**Low (Nice to Have):**
- Enhanced monitoring and alerting
- Additional redundancy (multi-AZ, failover)
- Advanced threat detection
