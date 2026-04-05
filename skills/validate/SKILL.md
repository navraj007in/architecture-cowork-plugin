---
name: validate
description: Run comprehensive quality checks on architecture blueprints. Validates completeness, consistency, best practices, and readiness for implementation. Identifies missing sections, conflicting decisions, and potential issues.
---

# Blueprint Validator

Run **comprehensive quality checks** on your architecture blueprint to ensure it's complete, consistent, and ready for implementation.

**Perfect for**: Pre-implementation review, quality assurance, stakeholder review prep, team handoff

---

## When to Use This Skill

Use this skill when you need to:
- Validate blueprint before sharing with stakeholders
- Check blueprint completeness before implementation
- Ensure all 19 sections are present and properly structured
- Verify consistency across sections (API → DB → Security)
- Validate against best practices
- Identify missing upgrade paths or assumptions
- Check for potential security issues
- Verify cost estimates are realistic

**Input**: Architecture blueprint (all 19 sections)
**Output**: Validation report with errors, warnings, and suggestions

---

## Validation Categories

### 1. Structural Completeness (Critical)

**Check**: All required sections present

**Required sections** (19 total):
1. Executive Summary
2. Product Type Detection
3. Tech Stack Decisions
4. Database Schema
5. Architecture Diagram
6. API Specification
7. Integrations
8. Security Architecture
9. Deployment & DevOps
10. Monitoring & Observability
11. Cost Estimate
12. Complexity Assessment
13. Service Level Objectives (SLOs)
14. Well-Architected Review
15. Sprint Backlog
16. Testing Strategy
17. Next Steps Guide
18. Required Accounts
19. Architecture Assumptions **(NEW)**

**Errors**:
- ❌ Section missing entirely
- ❌ Section header present but no content

**Warnings**:
- ⚠️ Section too short (< 3 paragraphs)
- ⚠️ Section lacks detail (< 500 characters)

### 2. Content Quality (High Priority)

**Check**: Each section has required subsections and details

#### Section 1: Executive Summary
- ✅ One-sentence product description
- ✅ Customer type (B2B/B2C)
- ✅ Problem statement
- ✅ Solution overview
- ✅ Key metrics (users, scale)
- ✅ Major assumptions called out

#### Section 3: Tech Stack Decisions
- ✅ Database choice with justification
- ✅ Hosting platform with cost
- ✅ Authentication provider
- ✅ All choices have confidence labels
- ✅ All choices have upgrade paths

#### Section 4: Database Schema
- ✅ At least 3 entities defined
- ✅ All entities have primary keys
- ✅ Foreign keys defined for relationships
- ✅ Indexes on foreign keys
- ✅ Multi-tenancy column if B2B
- ✅ Timestamps (created_at, updated_at)

#### Section 6: API Specification
- ✅ At least 5 endpoints documented
- ✅ All endpoints have HTTP methods
- ✅ Request/response examples provided
- ✅ Authentication requirements specified
- ✅ Error responses documented

#### Section 8: Security Architecture
- ✅ Authentication method specified
- ✅ Authorization strategy (RBAC, ABAC, etc.)
- ✅ Multi-tenancy isolation (if B2B)
- ✅ Secrets management approach
- ✅ OWASP Top 10 addressed

#### Section 11: Cost Estimate
- ✅ Infrastructure costs provided
- ✅ Cost ranges (not point estimates)
- ✅ At least 3 scenarios (MVP, Growth, Scale)
- ✅ Cost breakdown by service

#### Section 15: Sprint Backlog
- ✅ At least 5 sprints defined
- ✅ Each sprint has user stories
- ✅ User stories have acceptance criteria
- ✅ Story points provided
- ✅ Sprints are risk-prioritized

#### Section 19: Architecture Assumptions **(NEW)**
- ✅ All default choices documented
- ✅ Confidence labels used (Assumed/Recommended/Requires confirmation)
- ✅ Upgrade paths for each assumption
- ✅ Cost implications mentioned

### 3. Consistency Validation (High Priority)

**Cross-section checks**:

#### Database ↔ API Consistency
- ✅ All API endpoints reference valid database entities
- ✅ All database entities are exposed via API (or reason given)
- ❌ API returns fields not in database schema
- ❌ Database has orphaned entities (no API access)

#### Tech Stack ↔ Cost Estimate
- ✅ All tech stack choices appear in cost estimate
- ✅ Cost estimate matches chosen platforms
- ❌ Tech stack mentions Vercel, cost estimate shows AWS
- ❌ Database choice is PostgreSQL, cost shows MongoDB

#### Security ↔ Database
- ✅ If multi-tenant, database has tenant_id columns
- ✅ RLS policies mentioned if PostgreSQL + multi-tenant
- ❌ Multi-tenant product but no tenant isolation in schema

#### Sprint Backlog ↔ API/DB
- ✅ Sprint 0 includes database setup
- ✅ Sprints cover all major API endpoints
- ✅ Security features are prioritized early
- ❌ Sprint backlog missing critical infrastructure setup

#### Frontend ↔ Backend Connections
- ✅ All frontend `backend_connections` reference defined services
- ✅ All services consumed by frontends have endpoints documented
- ✅ Frontend `client_auth.token_storage` is compatible with auth strategy (e.g., cookie for web, secure-store for mobile)
- ✅ Frontend `realtime.protocol` matches service type (e.g., websocket service exists if frontend uses websocket)
- ❌ Frontend references a service not defined in `services[]`
- ❌ Frontend has no `backend_connections` but communicates with services via `communication[]`
- ⚠️ Mobile frontend missing `client_auth` configuration
- ⚠️ Frontend using `localStorage` for token storage with sensitive data (prefer `cookie` or `secure-store`)

#### Mobile ↔ Platform Checks
- ✅ iOS frontend has `bundle_id` defined
- ✅ Android frontend has `bundle_id` defined
- ✅ Push notification providers match platform (FCM for Android, APNS for iOS)
- ✅ Permissions listed match app functionality (camera if video calls, microphone if audio)
- ❌ Mobile frontend missing `push_providers` but backend has notification service
- ⚠️ Mobile frontend missing `deep_link_scheme` (needed for push notification deep links)
- ⚠️ Mobile frontend missing `ota_updates` (recommended for Expo/React Native apps)

### 4. Best Practices (Medium Priority)

**Architecture patterns**:
- ✅ Monolith recommended for new projects (not microservices)
- ✅ Managed platforms recommended over raw AWS/GCP
- ✅ PostgreSQL recommended over MongoDB for relational data
- ⚠️ Microservices for <10 engineers (premature optimization)
- ⚠️ Multiple databases in initial design (complexity)

**Security**:
- ✅ JWT expiration < 24 hours
- ✅ Password minimum length ≥ 8 characters
- ✅ Rate limiting on auth endpoints
- ✅ HTTPS enforced in production
- ❌ Secrets hardcoded in examples
- ❌ No rate limiting mentioned

**Database**:
- ✅ All foreign keys indexed
- ✅ Composite unique constraints for multi-tenant
- ✅ Soft deletes for important data
- ✅ Timestamps on all tables
- ⚠️ No indexes on frequently queried columns
- ⚠️ Missing cascade delete rules

**API Design**:
- ✅ RESTful naming conventions
- ✅ Pagination on list endpoints
- ✅ Proper HTTP status codes (201 for create, 204 for delete)
- ✅ API versioning strategy
- ⚠️ Inconsistent naming (camelCase vs snake_case)
- ⚠️ No filtering/sorting on list endpoints

### 5. Assumption-First Model Compliance **(NEW)**

**Check**: Blueprint follows Assumption-First principles

- ✅ Only 3-5 gating questions asked (not 8-12)
- ✅ All defaults have confidence labels
- ✅ All defaults have upgrade paths
- ✅ Architecture Invariants section present
- ✅ Architecture Assumptions appendix present
- ❌ Missing confidence labels on some defaults
- ❌ Missing upgrade paths for tech choices
- ⚠️ Asked for budget/timeline (should assume)

### 6. Upgrade Paths (Medium Priority)

**Check**: All decisions have upgrade paths

**Required for**:
- Database choice
- Hosting platform
- Architecture pattern (monolith → modular → microservices)
- Authentication provider
- Caching strategy
- File storage

**Format**:
```markdown
**Upgrade path**: Start with [X], upgrade to [Y] when [Z]
```

**Examples**:
- ✅ "Start with Vercel, upgrade to AWS when >100K users or SOC 2 required"
- ✅ "Start with monolith, upgrade to modular monolith when >10 engineers"
- ❌ "Use PostgreSQL" (no upgrade path)
- ❌ "Use Vercel for hosting" (no scale trigger)

### 7. Cost Validation (Medium Priority)

**Realistic cost ranges**:

**Infrastructure (monthly)**:
- MVP (< 1K users): $0-150
- Growth (1K-10K users): $150-500
- Scale (10K-100K users): $500-2000

**Development (one-time)**:
- AI tools: $20-60/month + time
- Freelancer: $20K-60K
- Agency: $60K-150K

**Errors**:
- ❌ MVP costs >$500/month (too high)
- ❌ Growth tier <$100/month (too low, unrealistic)
- ❌ No cost ranges (point estimates only)
- ❌ Missing cost breakdown

### 8. Security Checklist (High Priority)

**Check**: All OWASP Top 10 addressed

1. ✅ Broken Access Control → Authorization strategy defined
2. ✅ Cryptographic Failures → Secrets management, HTTPS
3. ✅ Injection → ORM usage, parameterized queries
4. ✅ Insecure Design → Well-Architected Review
5. ✅ Security Misconfiguration → Environment variables, RLS
6. ✅ Vulnerable Components → Dependency scanning mentioned
7. ✅ Identification/Authentication → Auth provider specified
8. ✅ Software/Data Integrity → Code signing, migrations
9. ✅ Logging/Monitoring → Observability section
10. ✅ SSRF → API security, input validation

**Warnings**:
- ⚠️ No mention of XSS prevention
- ⚠️ No CSRF protection strategy
- ⚠️ No SQL injection mitigation (if raw SQL used)

---

## Output Format

When invoked, generate:

```
🔍 Validating architecture blueprint...

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
STRUCTURAL COMPLETENESS
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

✅ All 19 required sections present
✅ All sections have content (>500 characters)

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
CONTENT QUALITY
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

✅ Executive Summary: Complete (product, customer, problem, solution)
✅ Tech Stack Decisions: 5 decisions with confidence labels
✅ Database Schema: 7 entities, all with PKs and indexes
✅ API Specification: 18 endpoints documented
⚠️  Security Architecture: Missing XSS prevention strategy
    → Add: "Sanitize all user input, use CSP headers"
✅ Cost Estimate: 3 scenarios ($50-150/month MVP to $500-1500/month Scale)
✅ Sprint Backlog: 8 sprints, 56 user stories, 134 story points
✅ Architecture Assumptions: All defaults with upgrade paths

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
CONSISTENCY VALIDATION
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

✅ Database ↔ API: All entities exposed, all endpoints valid
✅ Tech Stack ↔ Cost: All platforms in cost estimate
✅ Security ↔ Database: tenant_id columns present, RLS mentioned
❌ Sprint Backlog ↔ API: GET /analytics endpoint not in any sprint
    → Fix: Add analytics implementation to Sprint 5 or 6

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
BEST PRACTICES
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

✅ Architecture: Monolith recommended (appropriate for scale)
✅ Hosting: Managed platforms (Vercel + Supabase)
✅ Database: PostgreSQL with indexes and RLS
✅ Security: JWT expiration 15 minutes, rate limiting on auth
⚠️  Database: Missing index on tickets.created_at (used for sorting)
    → Add: CREATE INDEX tickets_created_at_idx ON tickets(created_at DESC)
⚠️  API: No pagination limit enforcement (should max at 100)
    → Add: Validate limit parameter: min=1, max=100

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
ASSUMPTION-FIRST COMPLIANCE
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

✅ Only 3 gating questions asked (customer type, scale, compliance)
✅ All tech defaults have confidence labels
✅ All defaults have upgrade paths
✅ Architecture Invariants section present
✅ Architecture Assumptions appendix complete
⚠️  File storage choice missing confidence label
    → Add: "Cloudflare R2 **(Recommended)** - Zero egress fees"

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
UPGRADE PATHS
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

✅ Database: "PostgreSQL (Supabase) → Dedicated PostgreSQL when >100K users"
✅ Hosting: "Vercel + Railway → AWS when SOC 2 or >100K users"
✅ Architecture: "Monolith → Modular monolith when >10 engineers"
✅ Auth: "Clerk → Auth0 when enterprise SSO required"
❌ Caching: No upgrade path defined
    → Add: "Start with in-memory cache, upgrade to Redis when >10K users"

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
COST VALIDATION
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

✅ MVP costs: $50-150/month (realistic)
✅ Growth costs: $150-500/month (realistic)
✅ Scale costs: $500-1500/month (realistic)
✅ Cost ranges provided (not point estimates)
✅ Cost breakdown by service
⚠️  No bandwidth costs mentioned (can be significant at scale)
    → Add: Bandwidth estimate for file downloads (R2 egress is free)

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
SECURITY CHECKLIST (OWASP Top 10)
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

✅ 1. Broken Access Control: RLS policies + RBAC
✅ 2. Cryptographic Failures: Secrets in env vars, HTTPS enforced
✅ 3. Injection: Prisma ORM (parameterized queries)
✅ 4. Insecure Design: Well-Architected Review included
✅ 5. Security Misconfiguration: Environment-based config
⚠️  6. Vulnerable Components: No dependency scanning mentioned
    → Add: "Use Dependabot or Snyk for dependency scanning"
✅ 7. Identification/Authentication: Clerk with JWT
✅ 8. Software/Data Integrity: Prisma migrations, code review
✅ 9. Logging/Monitoring: Sentry + structured logging
⚠️  10. SSRF: No mention of URL validation for integrations
    → Add: "Validate all external URLs before fetching"

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
VALIDATION SUMMARY
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

📊 Score: 87/100 (Good - Ready with minor fixes)

✅ Passed: 42 checks
⚠️  Warnings: 8 (fixable, non-blocking)
❌ Errors: 2 (should fix before implementation)

🎯 Recommendation: PROCEED WITH FIXES

Priority fixes:
1. ❌ Add analytics endpoint to sprint backlog (5 min fix)
2. ❌ Define caching upgrade path (2 min fix)
3. ⚠️  Add database index on tickets.created_at (1 line)
4. ⚠️  Add API pagination limit validation (2 lines)
5. ⚠️  Add dependency scanning to DevOps section (1 paragraph)

Blueprint is 87% complete and ready for implementation after addressing 2 critical issues and 8 warnings.

Next steps:
1. Fix 2 errors (analytics sprint, caching upgrade)
2. Review 8 warnings and decide which to address
3. Re-run validation to confirm 100% pass
4. Share with stakeholders using the stakeholder presentation workflow after validation passes
```

---

## Validation Levels

### 1. Strict (Default)
All errors must be fixed, warnings recommended.

**Use when**: Production blueprint, stakeholder review, team handoff

### 2. Relaxed
Warnings allowed, only errors block.

**Use when**: Early draft, rapid iteration, experimental designs

### 3. Pedantic
All warnings treated as errors.

**Use when**: Enterprise projects, compliance-heavy, security-critical

**Examples**:

```bash
# Default strict validation
/architect:sdl validate

# Relaxed (ignore warnings)
/architect:sdl validate --level=relaxed

# Pedantic (all warnings = errors)
/architect:sdl validate --level=pedantic
```

---

## Custom Validation Rules

Add project-specific rules:

**Example**:
```bash
/architect:sdl validate --rules=custom-rules.yaml
```

**custom-rules.yaml**:
```yaml
rules:
  - name: must_use_typescript
    severity: error
    check: tech_stack.language == "TypeScript"
    message: "All projects must use TypeScript (company policy)"

  - name: max_cost_mvp
    severity: error
    check: cost_estimate.mvp.max <= 200
    message: "MVP infrastructure costs must be <$200/month"

  - name: require_sentry
    severity: warning
    check: monitoring.includes("Sentry")
    message: "Sentry recommended for error tracking"

  - name: postgres_only
    severity: error
    check: database.type == "PostgreSQL"
    message: "Only PostgreSQL allowed (team expertise)"
```

---

## Auto-Fix Suggestions

For common issues, suggest fixes:

**Missing index**:
```bash
⚠️  Missing index on tickets.created_at

Auto-fix available:
  prisma/schema.prisma:42
  Add: @@index([createdAt])

Apply fix? [y/N]
```

**Missing upgrade path**:
```bash
❌ Caching choice has no upgrade path

Auto-fix suggestion:
  Section 3, line 127
  Add: "**Upgrade path**: Start with in-memory cache (Node.js Map),
        upgrade to Redis when >10K concurrent users or when session
        sharing needed across instances."

Apply fix? [y/N]
```

---

## Error Handling

### If blueprint file not found:
- **Action**: Error with guidance
- **Example**: "❌ blueprint.md not found. Run `/architect:blueprint` first."

### If blueprint is incomplete (< 10 sections):
- **Action**: Error with list of missing sections
- **Example**: "❌ Blueprint incomplete. Missing: Database Schema, API Spec, Security Architecture..."

### If blueprint is malformed (invalid markdown):
- **Action**: Warning, attempt to parse anyway
- **Example**: "⚠️ Malformed markdown detected. Attempting to parse..."

---

## Success Criteria

A passing validation should:
- ✅ All 19 sections present with content
- ✅ No critical errors (score ≥ 90/100)
- ✅ Warnings addressed or acknowledged
- ✅ Cross-section consistency validated
- ✅ Best practices followed
- ✅ Assumption-First model compliance
- ✅ All upgrade paths defined
- ✅ Cost estimates realistic
- ✅ Security checklist complete
- ✅ Ready for implementation or stakeholder review

---

## Examples

### Example 1: Basic Validation

```bash
/architect:sdl validate

# Output:
# 📊 Score: 87/100
# ✅ 42 checks passed
# ⚠️  8 warnings
# ❌ 2 errors
```

### Example 2: Relaxed Mode

```bash
/architect:sdl validate --level=relaxed

# Output:
# 📊 Score: 95/100 (warnings ignored)
# ✅ 42 checks passed
# ❌ 2 errors
```

### Example 3: With Auto-Fix

```bash
/architect:sdl validate --auto-fix

# Interactive prompts to apply suggested fixes
```

### Example 4: Custom Rules

```bash
/architect:sdl validate --rules=company-standards.yaml

# Validates against company-specific requirements
```

### Example 5: CI/CD Integration

```bash
# In GitHub Actions
- name: Validate Blueprint
  run: /architect:sdl validate --format=json --exit-code

# Exits with code 1 if validation fails
# Output: validation-report.json
```
