---
name: security-audit
description: Generate comprehensive security audit checklist from architecture blueprint. Covers OWASP Top 10, data security, authentication, authorization, secrets management, compliance, and testing procedures.
---

# Security Audit Checklist Generator

Generate a **comprehensive security audit checklist** tailored to your architecture blueprint for pre-launch security validation.

**Perfect for**: Pre-launch security review, compliance validation, penetration testing prep, security team handoff

---

## When to Use This Skill

Use this skill when you need to:
- Perform security review before launch
- Prepare for penetration testing
- Validate security controls are implemented
- Create security documentation for compliance (SOC 2, HIPAA)
- Onboard security team or auditors
- Create security testing plan
- Document security posture for investors/stakeholders

**Input**: Architecture blueprint (especially Section 8: Security Architecture)
**Output**: Security audit checklist (markdown + PDF)

---

## What's Generated

### 1. Security Audit Checklist

**security-audit-checklist.md**:
```markdown
# Security Audit Checklist
**Project**: Acme Ticketing Platform
**Generated**: 2026-02-07
**Architecture Version**: 1.0

---

## Overview

This checklist covers security controls for a **multi-tenant B2B SaaS** application built with:
- Frontend: Next.js 14 (Vercel)
- Backend: Next.js API Routes (Vercel)
- Database: PostgreSQL (Supabase)
- Auth: Clerk
- File Storage: Cloudflare R2

**Risk Level**: Medium (handles customer data, multi-tenant)
**Compliance**: None (SOC 2 planned for Year 2)

---

## 1. Authentication & Authorization

### 1.1 Authentication (Clerk)

- [ ] **Auth provider configured**: Clerk production keys set in environment
- [ ] **Password requirements enforced**: Minimum 8 characters, complexity rules
- [ ] **Email verification enabled**: Users must verify email before access
- [ ] **Password reset flow secure**: Reset tokens expire in 1 hour, single-use
- [ ] **Multi-factor authentication (MFA)**: Available for admin users
- [ ] **Session management**: JWT tokens expire in 15 minutes
- [ ] **Refresh tokens secure**: HttpOnly cookies, expire in 30 days
- [ ] **Account lockout**: After 5 failed login attempts, 15-minute lockout
- [ ] **OAuth providers**: Google OAuth configured and tested
- [ ] **Auth endpoints rate limited**: Max 5 login attempts per minute per IP

**Testing**:
- [ ] Attempt login with invalid credentials (should fail)
- [ ] Attempt login with expired token (should redirect to login)
- [ ] Verify MFA enforcement for admin accounts
- [ ] Test password reset flow end-to-end
- [ ] Verify session timeout after 15 minutes of inactivity

### 1.2 Authorization (RBAC)

- [ ] **Role-based access control (RBAC)**: Admin, Agent, Viewer roles defined
- [ ] **Permission matrix documented**: Each role's permissions listed
- [ ] **Admin-only routes protected**: Only admins can access workspace settings
- [ ] **Agent-only actions**: Only agents can be assigned tickets
- [ ] **Viewer restrictions**: Viewers can read but not modify tickets
- [ ] **Role escalation prevented**: Users cannot change their own role
- [ ] **Workspace isolation**: Users can only access their workspace data

**Testing**:
- [ ] Attempt to access admin route as Agent (should return 403)
- [ ] Attempt to modify ticket as Viewer (should return 403)
- [ ] Verify workspace isolation (user A cannot see user B's workspace)
- [ ] Test role downgrade (admin → agent should lose admin permissions)

---

## 2. Data Security

### 2.1 Multi-Tenant Data Isolation

- [ ] **Row-Level Security (RLS) enabled**: On all tables (tenants, users, tickets)
- [ ] **tenant_id on all tables**: Every row scoped by workspace
- [ ] **RLS policies tested**: Automated tests for each policy
- [ ] **Prisma middleware**: Automatically injects tenant_id filter
- [ ] **Cross-tenant leakage tested**: User A cannot query User B's data
- [ ] **Admin isolation**: Even admins cannot see other tenants without override

**Testing**:
- [ ] Run RLS test suite: `npm run test:rls`
- [ ] Manual test: Attempt cross-tenant query with modified SQL
- [ ] Verify Prisma middleware adds tenant_id to all queries
- [ ] Test with penetration testing tool (e.g., sqlmap)

### 2.2 Data Encryption

- [ ] **Data at rest encrypted**: Supabase encrypts all data (AES-256)
- [ ] **Data in transit encrypted**: HTTPS enforced (TLS 1.3)
- [ ] **Backup encryption**: Supabase backups are encrypted
- [ ] **Sensitive fields encrypted**: N/A (no PII beyond email)
- [ ] **Encryption keys rotated**: Managed by Supabase (automatic)

**Testing**:
- [ ] Verify HTTPS redirect (http://app.acme.com → https://app.acme.com)
- [ ] Check TLS version: `openssl s_client -connect app.acme.com:443`
- [ ] Verify no plaintext passwords in database (use Prisma to hash)

### 2.3 Secrets Management

- [ ] **No secrets in code**: All secrets in environment variables
- [ ] **Environment variables**: .env.local not committed to git
- [ ] **Secret rotation plan**: Rotate JWT_SECRET every 90 days
- [ ] **Vercel secrets**: All production secrets in Vercel dashboard
- [ ] **Database credentials**: Connection string in .env only
- [ ] **API keys encrypted**: All API keys stored as environment variables
- [ ] **Secret scanning**: GitHub secret scanning enabled

**Testing**:
- [ ] Scan repository for secrets: `git secrets --scan`
- [ ] Verify .gitignore excludes .env.local
- [ ] Check for hardcoded API keys: `grep -r "sk_live" .`

---

## 3. Application Security (OWASP Top 10)

### 3.1 Injection (A03:2021)

- [ ] **Parameterized queries**: Prisma ORM used (no raw SQL)
- [ ] **Input validation**: All user inputs validated (Zod schemas)
- [ ] **SQL injection prevented**: No string concatenation in queries
- [ ] **NoSQL injection**: N/A (PostgreSQL used)
- [ ] **Command injection**: No shell commands from user input
- [ ] **LDAP injection**: N/A (no LDAP integration)

**Testing**:
- [ ] Attempt SQL injection: `' OR 1=1 --` in email field
- [ ] Attempt command injection: `; rm -rf /` in file upload
- [ ] Use SQLMap to scan for SQL injection vulnerabilities

### 3.2 Broken Access Control (A01:2021)

- [ ] **Direct object reference**: All queries scoped by tenant_id
- [ ] **Forced browsing**: Cannot access /admin without admin role
- [ ] **Missing function level access control**: API checks roles
- [ ] **Insecure direct object references**: Ticket IDs not guessable (CUID)
- [ ] **CORS configured**: Only allow app.acme.com origin

**Testing**:
- [ ] Attempt to access /api/tickets/:id from different tenant
- [ ] Attempt to access /admin as non-admin user
- [ ] Verify CORS headers: `curl -H "Origin: https://evil.com" https://api.acme.com`

### 3.3 Cryptographic Failures (A02:2021)

- [ ] **HTTPS enforced**: All traffic over HTTPS (no HTTP)
- [ ] **TLS 1.3 enabled**: Modern TLS version
- [ ] **Strong cipher suites**: Only secure ciphers allowed
- [ ] **HSTS enabled**: Strict-Transport-Security header set
- [ ] **Password hashing**: Bcrypt with 10+ rounds (handled by Clerk)
- [ ] **Session tokens**: JWT with HS256 algorithm

**Testing**:
- [ ] Verify HSTS header: `curl -I https://app.acme.com`
- [ ] Check TLS version: `nmap --script ssl-enum-ciphers -p 443 app.acme.com`
- [ ] Verify no weak ciphers (3DES, RC4, MD5)

### 3.4 Cross-Site Scripting (XSS)

- [ ] **Input sanitization**: All user input escaped (React auto-escapes)
- [ ] **Content-Security-Policy (CSP)**: CSP header configured
- [ ] **X-XSS-Protection**: Header enabled
- [ ] **Dangerous HTML disabled**: No dangerouslySetInnerHTML used
- [ ] **User-generated content sanitized**: DOMPurify for rich text

**Testing**:
- [ ] Attempt XSS: `<script>alert('XSS')</script>` in ticket title
- [ ] Verify CSP header blocks inline scripts
- [ ] Test with XSS payloads: `<img src=x onerror=alert(1)>`

### 3.5 Cross-Site Request Forgery (CSRF)

- [ ] **CSRF tokens**: Next.js API routes have CSRF protection
- [ ] **SameSite cookies**: Session cookies use SameSite=Strict
- [ ] **Double-submit cookies**: Additional CSRF protection for forms
- [ ] **State-changing requests**: Only POST/PUT/DELETE (not GET)

**Testing**:
- [ ] Attempt CSRF attack from external site
- [ ] Verify SameSite cookie attribute: `document.cookie` in console

### 3.6 Security Misconfiguration (A05:2021)

- [ ] **Default credentials changed**: No default admin/admin accounts
- [ ] **Debug mode disabled**: NODE_ENV=production
- [ ] **Error messages sanitized**: No stack traces in production
- [ ] **Unnecessary services disabled**: No unused API endpoints
- [ ] **Security headers**: X-Frame-Options, X-Content-Type-Options
- [ ] **Directory listing disabled**: Vercel disables by default

**Testing**:
- [ ] Verify production environment: Check NODE_ENV
- [ ] Trigger error and verify no stack trace shown
- [ ] Check security headers: `curl -I https://app.acme.com`

### 3.7 Vulnerable Components (A06:2021)

- [ ] **Dependency scanning**: Dependabot or Snyk enabled
- [ ] **Package vulnerabilities**: `npm audit` shows no high/critical
- [ ] **Outdated packages**: All packages within 1 major version
- [ ] **License compliance**: No GPL/AGPL packages (if commercial)

**Testing**:
- [ ] Run: `npm audit --audit-level=high`
- [ ] Run: `npm outdated`
- [ ] Check for known vulnerabilities in dependencies

### 3.8 Logging & Monitoring (A09:2021)

- [ ] **Authentication events logged**: Login, logout, failed attempts
- [ ] **Authorization failures logged**: 403 errors logged to Sentry
- [ ] **Input validation failures logged**: Malformed requests logged
- [ ] **Centralized logging**: All logs sent to Sentry or Datadog
- [ ] **Log retention**: Logs retained for 90 days minimum
- [ ] **Alerting configured**: Alerts on repeated failed logins

**Testing**:
- [ ] Verify failed login is logged: Check Sentry dashboard
- [ ] Trigger 403 error and verify logged
- [ ] Check log retention policy in logging provider

### 3.9 Server-Side Request Forgery (SSRF)

- [ ] **URL validation**: All external URLs validated before fetching
- [ ] **Whitelist approach**: Only allow known domains (e.g., Slack API)
- [ ] **No user-controlled URLs**: Users cannot specify fetch URLs
- [ ] **Network segmentation**: API cannot access internal networks

**Testing**:
- [ ] Attempt to fetch internal URL: `http://169.254.169.254/` (AWS metadata)
- [ ] Verify URL whitelist blocks unknown domains

### 3.10 Insecure Design (A04:2021)

- [ ] **Threat modeling**: Well-Architected Review completed
- [ ] **Security requirements**: Defined in blueprint (Section 8)
- [ ] **Rate limiting**: All public endpoints rate limited
- [ ] **Input validation**: All inputs validated with Zod schemas
- [ ] **Secure defaults**: Fail-secure (deny by default)

**Testing**:
- [ ] Review Well-Architected Review section of blueprint
- [ ] Verify rate limiting: Exceed limit and get 429 response

---

## 4. API Security

### 4.1 API Authentication

- [ ] **Bearer tokens**: All protected endpoints require JWT
- [ ] **Token validation**: Verify JWT signature and expiration
- [ ] **Token in Authorization header**: Not in URL or body
- [ ] **API key rotation**: Clerk keys rotated every 90 days

**Testing**:
- [ ] Call API without token (should return 401)
- [ ] Call API with expired token (should return 401)
- [ ] Verify token not in URL: Check access logs

### 4.2 Rate Limiting

- [ ] **Global rate limit**: 60 requests/minute per IP
- [ ] **Auth endpoints**: 5 requests/minute per IP
- [ ] **Rate limit headers**: X-RateLimit-Limit, X-RateLimit-Remaining
- [ ] **Rate limit bypass prevented**: Cannot bypass with IP spoofing
- [ ] **DDoS protection**: Vercel DDoS mitigation enabled

**Testing**:
- [ ] Exceed rate limit and verify 429 response
- [ ] Check rate limit headers in response
- [ ] Attempt IP spoofing to bypass rate limit

### 4.3 Input Validation

- [ ] **Request validation**: All requests validated with Zod
- [ ] **Type checking**: TypeScript types enforced
- [ ] **String length limits**: Max lengths enforced (title: 200 chars)
- [ ] **Numeric ranges**: Valid ranges (priority: 1-4)
- [ ] **Enum validation**: Status must be OPEN|IN_PROGRESS|RESOLVED|CLOSED

**Testing**:
- [ ] Send invalid JSON (malformed)
- [ ] Send extra-long strings (>1MB)
- [ ] Send invalid enum values

### 4.4 Output Encoding

- [ ] **JSON responses**: Properly encoded (application/json)
- [ ] **No sensitive data**: Passwords, tokens excluded from responses
- [ ] **Error messages**: Generic (not revealing internal details)
- [ ] **Stack traces**: Never returned in production

**Testing**:
- [ ] Verify passwords not in user object response
- [ ] Trigger error and verify generic message
- [ ] Check Content-Type header: application/json

---

## 5. File Upload Security

### 5.1 Upload Validation

- [ ] **File type validation**: Only allow images (PNG, JPG, GIF, WebP)
- [ ] **File size limit**: Max 10MB per file
- [ ] **Virus scanning**: Cloudflare R2 scans uploads
- [ ] **Content-Type validation**: Check MIME type, not just extension
- [ ] **File name sanitization**: Remove special characters

**Testing**:
- [ ] Upload executable (.exe, .sh) - should reject
- [ ] Upload >10MB file - should reject
- [ ] Upload file with malicious name: `../../etc/passwd.jpg`

### 5.2 Storage Security

- [ ] **Presigned URLs**: R2 presigned URLs for uploads (expire in 1 hour)
- [ ] **Private buckets**: R2 bucket not publicly listable
- [ ] **Access control**: Only authenticated users can upload
- [ ] **CDN caching**: Uploaded files served via CDN with cache headers
- [ ] **URL randomization**: File URLs not guessable (UUID)

**Testing**:
- [ ] Attempt to list bucket contents (should fail)
- [ ] Attempt to access file without presigned URL
- [ ] Verify presigned URL expires after 1 hour

---

## 6. Compliance & Privacy

### 6.1 Data Privacy (GDPR)

- [ ] **Privacy policy**: Published and linked in footer
- [ ] **Cookie consent**: Banner shown for EU users
- [ ] **Data deletion**: Users can delete their account and data
- [ ] **Data export**: Users can export their data (tickets, comments)
- [ ] **Data retention**: Soft deletes, 90-day grace period
- [ ] **Third-party processors**: Documented (Clerk, Supabase, Vercel)

**Testing**:
- [ ] Verify privacy policy link works
- [ ] Test account deletion flow
- [ ] Test data export (download JSON)

### 6.2 HIPAA (If Healthcare)

- [ ] **N/A**: No healthcare data in this application

### 6.3 SOC 2 (If Enterprise SaaS)

- [ ] **Planned for Year 2**: Not currently required

---

## 7. Infrastructure Security

### 7.1 Network Security

- [ ] **Firewall rules**: Managed by Vercel and Supabase
- [ ] **Private networks**: Database not publicly accessible
- [ ] **VPN access**: N/A (managed platforms)
- [ ] **IP whitelisting**: Admin panel IP-restricted (optional)

**Testing**:
- [ ] Attempt to connect to database from public IP (should fail)
- [ ] Verify Supabase connection pooler security

### 7.2 Database Security

- [ ] **Database backups**: Supabase backs up every 5 minutes
- [ ] **Backup encryption**: Encrypted at rest
- [ ] **Point-in-time recovery**: Available (last 7 days)
- [ ] **Connection pooling**: Supabase Pooler enabled
- [ ] **Database credentials**: Rotated every 90 days
- [ ] **Database firewall**: Only allow connections from Vercel IPs

**Testing**:
- [ ] Verify backups exist in Supabase dashboard
- [ ] Test point-in-time recovery (staging only)
- [ ] Attempt to connect from unauthorized IP

### 7.3 Container/Serverless Security

- [ ] **Vercel runtime**: Secure by default (sandboxed)
- [ ] **Environment isolation**: Staging and production separated
- [ ] **No root access**: Serverless functions run as non-root
- [ ] **Resource limits**: Memory and CPU limits enforced

**Testing**:
- [ ] Verify staging and production use different databases
- [ ] Check Vercel deployment logs for errors

---

## 8. Monitoring & Incident Response

### 8.1 Security Monitoring

- [ ] **Sentry configured**: Error tracking enabled
- [ ] **Failed login tracking**: Alerts on >10 failed logins/minute
- [ ] **Anomaly detection**: Unusual traffic patterns alert
- [ ] **Log analysis**: Automated log analysis for threats
- [ ] **Uptime monitoring**: Vercel Analytics enabled

**Testing**:
- [ ] Trigger 10 failed logins and verify alert
- [ ] Verify Sentry receives errors
- [ ] Check uptime monitoring dashboard

### 8.2 Incident Response Plan

- [ ] **Incident response team**: CTO + Lead Dev
- [ ] **Escalation procedure**: Documented in runbook
- [ ] **Communication plan**: Email + Slack for incidents
- [ ] **Breach notification**: 72-hour GDPR timeline
- [ ] **Post-mortem process**: RCA within 48 hours

**Testing**:
- [ ] Review incident response runbook
- [ ] Simulate incident and test escalation

---

## 9. Security Testing

### 9.1 Automated Testing

- [ ] **Unit tests for auth**: 95% coverage on auth flows
- [ ] **Integration tests**: API endpoint tests with auth
- [ ] **E2E tests**: Playwright tests for critical flows
- [ ] **Security linting**: ESLint security rules enabled
- [ ] **Dependency scanning**: Automated (Dependabot)

**Testing**:
- [ ] Run: `npm run test` (95% coverage achieved)
- [ ] Run: `npm run test:e2e`
- [ ] Check ESLint security plugin enabled

### 9.2 Manual Testing

- [ ] **Penetration testing**: Scheduled for before launch
- [ ] **Code review**: Security-focused code review
- [ ] **Threat modeling**: Completed in blueprint
- [ ] **Red team exercise**: N/A (planned for Year 2)

**Testing**:
- [ ] Schedule penetration test with vendor (Bishop Fox, etc.)
- [ ] Conduct internal security code review

---

## 10. Third-Party Integrations

### 10.1 Integration Security

- [ ] **Slack integration**: Webhook URL in environment variable
- [ ] **Stripe integration**: Webhook signature verification
- [ ] **OAuth scopes**: Minimum required scopes only
- [ ] **API keys rotated**: Every 90 days
- [ ] **Webhook validation**: Verify signatures on all webhooks

**Testing**:
- [ ] Verify Stripe webhook signature validation
- [ ] Test Slack webhook with invalid signature
- [ ] Review OAuth scope requests (minimum principle)

---

## Pre-Launch Checklist

**Critical (Must Fix Before Launch)**:
- [ ] All RLS policies tested and passing
- [ ] Penetration test completed with no critical findings
- [ ] Rate limiting enabled on all public endpoints
- [ ] HTTPS enforced everywhere
- [ ] Secrets not in code repository
- [ ] Database backups configured and tested
- [ ] Error tracking (Sentry) configured
- [ ] Security headers configured
- [ ] Input validation on all endpoints
- [ ] Authentication and authorization tested

**High Priority (Should Fix Before Launch)**:
- [ ] XSS prevention tested
- [ ] CSRF protection enabled
- [ ] File upload validation working
- [ ] Dependency vulnerabilities resolved
- [ ] Logging and monitoring configured
- [ ] Privacy policy published
- [ ] Data export functionality working

**Medium Priority (Fix Within 30 Days)**:
- [ ] MFA available for admin users
- [ ] Security documentation complete
- [ ] Incident response plan documented
- [ ] Cookie consent for EU users
- [ ] Account lockout after failed attempts

---

## Sign-Off

**Security Review Completed By**: _______________________

**Date**: _______________________

**Security Posture**: ☐ Ready for Launch  ☐ Needs Fixes  ☐ Major Issues

**Notes**:
_______________________________________________________________
_______________________________________________________________
_______________________________________________________________

**Next Security Review Date**: _______________________
```

---

## Output Format

When invoked, generate:

```
🔒 Generating security audit checklist...

✅ Analyzed security architecture (Section 8)
✅ Detected product type: Multi-tenant B2B SaaS
✅ Detected authentication: Clerk (JWT)
✅ Detected database: PostgreSQL with RLS
✅ Detected compliance requirements: None (SOC 2 planned)

📋 Generating checklist sections...
✅ 1. Authentication & Authorization (25 checks)
✅ 2. Data Security (18 checks)
✅ 3. Application Security - OWASP Top 10 (47 checks)
✅ 4. API Security (22 checks)
✅ 5. File Upload Security (11 checks)
✅ 6. Compliance & Privacy (8 checks)
✅ 7. Infrastructure Security (12 checks)
✅ 8. Monitoring & Incident Response (9 checks)
✅ 9. Security Testing (8 checks)
✅ 10. Third-Party Integrations (5 checks)

📄 Created security-audit-checklist.md (287 checks total)
📄 Created security-audit-summary.pdf (executive summary)

🎯 Checklist tailored to your architecture:
- Multi-tenant data isolation (RLS)
- Clerk authentication
- Cloudflare R2 file uploads
- Stripe integration security
- Slack webhook validation

🚨 Critical security items (must fix before launch):
1. Enable and test Row-Level Security policies
2. Configure rate limiting on authentication endpoints
3. Schedule penetration testing (budget: $5K-15K)
4. Verify HTTPS enforced everywhere
5. Test webhook signature validation (Stripe, Slack)

📋 Pre-launch checklist: 35 critical items

Next steps:
1. Review security-audit-checklist.md with team
2. Assign checklist items to developers
3. Schedule penetration testing
4. Complete all critical items before launch
5. Sign off on security review
```

---

## Customization Options

**Optional parameters**:

1. **Compliance level**: None, GDPR, HIPAA, SOC 2, PCI-DSS
2. **Risk level**: Low, Medium, High, Critical
3. **Include penetration test**: Yes/No
4. **Format**: Markdown (default), PDF, DOCX, Checklist app

**Examples**:

```bash
# Basic security audit
/architect:security-audit

# HIPAA compliance
/architect:security-audit --compliance=hipaa

# High-risk application
/architect:security-audit --risk=high

# Export to PDF
/architect:security-audit --format=pdf
```

---

## Success Criteria

A comprehensive security audit checklist should:
- ✅ Cover all OWASP Top 10 vulnerabilities
- ✅ Address multi-tenant security (if B2B)
- ✅ Include authentication and authorization checks
- ✅ Cover data encryption (at rest and in transit)
- ✅ Address API security (rate limiting, validation)
- ✅ Include file upload security (if applicable)
- ✅ Address compliance requirements (GDPR, HIPAA, etc.)
- ✅ Include infrastructure security checks
- ✅ Have monitoring and incident response plan
- ✅ Be tailored to specific architecture (not generic)

---

## Examples

### Example 1: Basic Audit

```bash
/architect:security-audit

# Output: security-audit-checklist.md with 287 checks
```

### Example 2: HIPAA Compliance

```bash
/architect:security-audit --compliance=hipaa

# Additional checks: PHI encryption, BAA vendors, audit logs
```

### Example 3: PDF Export

```bash
/architect:security-audit --format=pdf

# Output: security-audit-checklist.pdf for printing
```
