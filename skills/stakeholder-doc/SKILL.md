---
name: stakeholder-doc
description: Generate presentation-ready Word documents for stakeholder discussions. Translates technical architecture blueprints into business-focused presentations with diagrams, cost analysis, and approval checklists.
---

# Stakeholder Document Generator

Transform technical architecture blueprints into **presentation-ready documents** for executive presentations, budget approvals, and stakeholder buy-in.

**Perfect for**: CTO reviews, board presentations, finance approvals, agency RFPs, investor updates

---

## When to Use This Skill

Use this skill when you need to:
- Present architecture to non-technical stakeholders (executives, product managers, business teams)
- Get budget approval for development costs
- Share technical decisions with wider team before proceeding
- Create RFPs for agency vendors
- Document architectural decisions for compliance/audit

**Input**: Full architecture blueprint (from `/architect:blueprint`)
**Output**: Word document (.docx) with diagrams rendered as PNGs

---

## Document Structure

### 1. Cover Page

```markdown
# [Project Name]
## Architecture & Implementation Plan

**Prepared for**: [Stakeholder Name/Team]
**Prepared by**: Architect AI
**Date**: [Today's Date]
**Version**: 1.0
```

---

### 2. Executive Summary (1 page max)

**Translate technical blueprint into business value:**

```markdown
## Executive Summary

**What we're building**: [One-sentence description from blueprint]

**Who it's for**: [Customer type from requirements - B2B enterprise/SMB/B2C]

**Business Value**:
- [Extract from blueprint: What problem does this solve?]
- [Key capability that drives value]
- [Integration or feature that reduces friction]

**Timeline**:
- MVP (core features): [Calculate from sprint backlog - usually 8 weeks]
- Production-ready: [Add 4 weeks for enterprise features if B2B]

**Budget**:
- Infrastructure: $[Low]-[High]/month (from cost estimate section)
- Development: $[Low]-[High] (from Next Steps - 3 build paths)

**Major Risks** (top 3):
1. [Extract from Complexity Assessment - highest-scored complexity factors]
   - **Mitigation**: [From blueprint's risk mitigation notes]
2. [Second highest risk]
   - **Mitigation**: [Strategy]
3. [Third risk]
   - **Mitigation**: [Strategy]

**Recommendation**: GO - Architecture is sound, risks are manageable, timeline is realistic.
[Or: PROCEED WITH CAUTION if complexity score > 7/10]
```

**Rules**:
- Use **non-technical language** (translate JWT → "secure login tokens", RLS → "data isolation", etc.)
- Lead with **business impact**, not technical features
- Keep to **1 page maximum**
- Include **confidence level** in recommendation (High/Medium/Low based on complexity score)

---

### 3. Solution Overview

#### 3.1 High-Level Architecture Diagram

**Extract from blueprint's Architecture Diagram section:**
- Take the C4 Container diagram (Mermaid code)
- **Render to PNG** (1200px width minimum)
- Caption: "System components and how they connect"

**Simplify for non-technical audience**:
- Frontend → "User Interface (Web/Mobile)"
- Backend → "Business Logic Server"
- Database → "Data Storage"
- Keep external integrations (Stripe, Slack, etc.) - business stakeholders recognize these

#### 3.2 Solution Components Table

Extract from blueprint and present as table:

| Component | Technology | Purpose | Cost/Month |
|-----------|------------|---------|------------|
| [From manifest: frontend] | [Framework] | User interface | $[From cost estimate] |
| [From manifest: backend] | [Framework] | Business logic | $[From cost estimate] |
| [From manifest: database] | [Type] | Data storage | $[From cost estimate] |
| [From manifest: integrations] | [Services] | [Purpose] | $[From cost estimate] |
| **Total** | | | **$[Sum]/month** |

#### 3.3 Key Capabilities Checklist

Extract from blueprint's Plain English Specifications:
- ✅ [Feature 1 from specs]
- ✅ [Feature 2 from specs]
- ✅ [Feature 3 from specs]
- ✅ [Critical integration]
- ✅ [Security/compliance feature if mentioned]

Limit to **top 6 capabilities** that stakeholders care about.

---

### 4. Technology Stack & Decisions

**For each major technology decision, create a decision card:**

Extract from:
- Database Schema section → Database choice
- Architecture Diagram → Hosting choice
- Application Architecture section → Architecture pattern
- Product Type Detection → Multi-tenancy approach (if B2B)

#### Template for Each Decision:

```markdown
### Decision: [Technology Category] - [Choice] ✅ Recommended

**Why [Choice]?**
- ✅ [Business benefit 1 - extract from blueprint's tech stack reasoning]
- ✅ [Business benefit 2]
- ✅ [Cost or hiring benefit]
- ✅ [Proven track record - if mentioned in blueprint]

**Alternatives Considered**:
- ❌ [Alternative 1]: [Why rejected - from blueprint's ADRs or alternatives]
- ❌ [Alternative 2]: [Why rejected]

**Upgrade Path**: [From blueprint's assumptions - "Start with X, upgrade to Y when Z"]

**Risk**: [Low/Medium/High based on blueprint's complexity assessment]
```

**Example** (using blueprint data):

```markdown
### Decision: Database - PostgreSQL ✅ Recommended

**Why PostgreSQL?**
- ✅ Handles relational data (tickets, users, workspaces) efficiently
- ✅ Used by Instagram, Notion, Figma - proven at scale
- ✅ $0-25/month free tier, scales to millions of users
- ✅ Built-in multi-tenancy support (Row-Level Security)

**Alternatives Considered**:
- ❌ MongoDB: Doesn't fit relational data model, harder data integrity
- ❌ MySQL: Less feature-rich, weaker JSON support

**Upgrade Path**: Start with Supabase free tier → Upgrade to Pro ($25/month) at 1K users

**Risk**: Low - Industry standard with massive community support
```

**Generate decision cards for**:
1. Database
2. Hosting (managed platforms vs AWS/GCP)
3. Architecture pattern (monolith vs microservices)
4. Multi-tenancy approach (if B2B product detected)

**Add ⚠️ "Requires Validation"** flag if:
- Complexity score for this decision > 6/10
- Blueprint mentions "needs validation" or "confirm with user"
- Security-critical decision (e.g., multi-tenant data isolation)

---

### 5. Cost Breakdown

Extract from blueprint's Cost Estimate section.

#### 5.1 Infrastructure Costs (monthly recurring)

Create 3 scenarios from blueprint:

| Scenario | User Count | Cost/Month | Cost/Year | Notes |
|----------|-----------|-----------|-----------|-------|
| **MVP** | [From blueprint scale assumptions] | $[Low] | $[Low × 12] | Free tiers sufficient |
| **Growth** | [10x MVP] | $[Mid] | $[Mid × 12] | Paid tiers + scaling |
| **Scale** | [100x MVP] | $[High] | $[High × 12] | Enterprise tiers |

**Breakdown** (Growth scenario):
[List each service from cost estimate with monthly cost]

#### 5.2 Development Costs (one-time)

Extract from blueprint's Next Steps Guide (3 build paths):

| Path | Cost | Timeline | Best For |
|------|------|----------|----------|
| Build with AI tools | $[From Next Steps] | [Weeks] | Technical founders |
| Hire developer | $[From Next Steps] | [Weeks] | Budget $20K-50K |
| Hire agency | $[From Next Steps] | [Weeks] | Enterprise projects |

#### 5.3 Total First-Year Cost

Calculate:
```
Development: $[Choose middle path - hire developer]
Infrastructure: $[Growth tier × 12]
Third-party: $[Domain + other one-time costs]
Total Year 1: $[Sum]
```

---

### 6. Major Architectural Decisions & Defense

**Q&A format for common stakeholder questions:**

Extract from blueprint and translate to Q&A:

#### Q: Why not use AWS instead of [recommended hosting]?

**A**: [Extract from blueprint's hosting decision reasoning, translate to business terms]

**Example**:
> AWS requires a DevOps engineer ($120K/year salary). Managed platforms (Vercel + Supabase) handle deployment, scaling, and backups automatically for $1,800/year. **We save $118K/year** and ship 3-5x faster.
>
> **When to switch**: When you reach >100K users or need enterprise compliance (SOC 2), estimated 12-18 months away.

#### Q: Why monolith instead of microservices?

**A**: [Extract from blueprint's architecture pattern decision]

#### Q: How do we prevent [top security concern from blueprint]?

**A**: [Extract security mitigations from Security Architecture section]

**Rules**:
- **Lead with business impact** ($$ savings, time savings, risk reduction)
- Include "**When to switch**" for each decision (upgrade path)
- Keep answers to 2-3 sentences max

---

### 7. Risk Assessment

Extract from blueprint's Complexity Assessment and Well-Architected Review.

Create risk table:

| Risk | Severity | Probability | Mitigation | Owner |
|------|----------|-------------|------------|-------|
| [Top complexity factor] | High/Med/Low | High/Med/Low | [From blueprint's mitigation notes] | Dev Team/CTO |
| [Second factor] | ... | ... | ... | ... |
| [Third factor] | ... | ... | ... | ... |

**Severity calculation**:
- **High**: Complexity score 7-10/10
- **Medium**: Complexity score 4-6/10
- **Low**: Complexity score 1-3/10

**Probability**:
- Extract from blueprint's risk flags or assume:
  - High: New/unproven technology
  - Medium: Standard technology, some complexity
  - Low: Proven patterns, low complexity

**Add these standard risks**:
- Vendor lock-in: Low severity, High probability → Mitigation: Exit strategy documented
- Budget overrun: Medium severity, Low probability → Mitigation: Fixed-price contracts + monthly caps
- Timeline slippage: Medium severity, Medium probability → Mitigation: Risk-prioritized sprints

---

### 8. Timeline & Milestones

Extract from blueprint's Sprint Backlog section.

Convert sprints to milestone table:

| Phase | Duration | Deliverables | Success Criteria |
|-------|----------|--------------|------------------|
| **Sprint 0: Setup** | 1 week | [From sprint 0 goals] | ✅ [From acceptance criteria] |
| **Sprint 1: [Feature]** | [Duration] | [From sprint goals] | ✅ [From acceptance criteria] |
| **Sprint 2: [Feature]** | [Duration] | [From sprint goals] | ✅ [From acceptance criteria] |
| ... | ... | ... | ... |
| **MVP Launch** | **[Total weeks]** | All core features | ✅ [From sprint backlog MVP definition] |
| **Production** | **[Total + 4 weeks]** | Enterprise-ready | ✅ First paying customer |

**Highlight critical path**:
> **Critical Path**: [Identify hardest/riskiest sprints from backlog] - any delay here impacts launch

---

### 9. Success Metrics

Extract from blueprint's Service Level Objectives and Next Steps.

**MVP Success** (Week [calculated from sprint backlog]):
- ✅ [From SLO section: availability target]
- ✅ [From SLO section: latency target]
- ✅ [User count target from scale assumptions]
- ✅ Infrastructure costs < $[from cost estimate]

**Production Success** (Week [MVP + 4]):
- ✅ First paying customer onboarded
- ✅ [From SLO: uptime achieved]
- ✅ [From SLO: performance target]
- ✅ Security audit completed (if mentioned in security section)

**Business Success** (6 months):
- [Infer based on product type and scale]:
  - B2B SaaS: 100+ paying customers, $10K+ MRR
  - B2C: 10K+ active users, <5% churn
  - Marketplace: $100K+ GMV

---

### 10. Next Steps & Approval Checklist

**Immediate Actions** (if approved):

Extract from blueprint's Next Steps Guide:

- [ ] **Week 1**: Run `/architect:scaffold` to bootstrap repos
- [ ] **Week 1**: Setup accounts [list from Required Accounts section]
- [ ] **Week 1**: Configure CI/CD pipeline
- [ ] **Week 1-2**: [Hire developers if external team]
- [ ] **Week 2**: Sprint 0 complete (can deploy to production)

**Approval Checklist**:

- [ ] **Budget approved**: $[Development cost] + $[Infrastructure/month]
- [ ] **Timeline approved**: [Weeks to MVP]
- [ ] **Major tech decisions approved**: [Database, hosting, architecture pattern]
- [ ] **Risk mitigation approved**: [Top 3 risks from risk table]
- [ ] **Success metrics agreed**: [From Success Metrics section]

**Decision Required By**: [Today + 2 weeks]

**Approved By**: ___________________________ Date: ___________

---

### 11. Appendices

#### A. Glossary

Auto-generate from technical terms used in document:

- **API**: How software components talk to each other
- **Backend**: Server-side code that processes data
- **Database**: Where all data is stored
- **Frontend**: User interface in the browser
- **Monolith**: Single application (vs many small services)
- **Multi-tenant**: Multiple customers share infrastructure, data isolated
- **PostgreSQL**: Database used by Instagram, Notion, Figma
- **Row-Level Security (RLS)**: Database security that isolates customer data
- **SaaS**: Software accessed via web browser
- **SSO**: Login with company credentials

**Rule**: Only include terms actually used in the document.

#### B. Technical Diagrams (as PNGs)

Render these diagrams from blueprint as PNG:
1. Architecture diagram (C4 Container)
2. Database schema (ERD) - if included in blueprint
3. User flow diagrams - if included
4. Deployment diagram - if included

**Minimum width**: 1200px for clarity

#### C. Reference Links

- Full architecture blueprint (link to markdown file)
- Sprint backlog (link to detailed user stories)
- Cost calculator (link if interactive spreadsheet exists)

---

## Document Formatting

**Output as Markdown** (can be converted to .docx):

```markdown
# [Project Name]
## Architecture & Implementation Plan

---

## Executive Summary
[Content...]

---

## Solution Overview
[Content...]

![Architecture Diagram](./diagrams/architecture.png)
*System components and how they connect*

---

[Continue with all 11 sections...]
```

**Style Guidelines**:
- Use `##` for main sections (Executive Summary, Solution Overview, etc.)
- Use `###` for subsections
- Use tables for structured data (costs, components, risks, timeline)
- Use ✅ for success criteria and capabilities
- Use ❌ for alternatives rejected
- Use ⚠️ for requires validation
- Use **bold** for emphasis on business-critical points
- Use `code` only for actual technical terms that need monospace

---

## Output Format

When invoked, generate:

```
📄 Generating stakeholder document...

✅ Extracted executive summary from blueprint
✅ Rendered architecture diagram to PNG (1200x800)
✅ Compiled tech stack decisions (4 decisions)
✅ Calculated cost breakdown (3 scenarios)
✅ Generated risk assessment (6 risks)
✅ Created timeline from sprint backlog (8 sprints, 12 weeks total)
✅ Added approval checklist

📄 stakeholder-presentation.md created (11 sections, 2,847 words)
📁 diagrams/ folder created with 1 PNG

Ready to share with stakeholders!

Next steps:
- Convert to .docx: Use Pandoc or copy into Word
- Review and customize for your stakeholder audience
- Add company logo to cover page
- Update "Decision Required By" date
```

---

## Customization Options

**Optional parameters** (ask user if they want to customize):

1. **Stakeholder name/title**: "CTO Review Committee", "Board of Directors", etc.
2. **Budget constraints**: Max budget to flag in recommendations
3. **Timeline constraints**: Must-launch-by date to compare against
4. **Company logo**: Upload for cover page
5. **Custom branding**: Color scheme, fonts

**Default behavior**: Generate with standard formatting if no customization requested.

---

## Success Criteria

A good stakeholder document should:
- ✅ Be understandable by non-technical executives
- ✅ Articulate business value (not just technical features)
- ✅ Include realistic timelines and costs (not optimistic best-case)
- ✅ Address risks upfront with mitigation strategies
- ✅ Provide clear recommendation (Go/No-Go with confidence)
- ✅ Include approval checklist for decision-making
- ✅ Use visual diagrams (PNGs, not Mermaid text)
- ✅ Defend technical decisions with business justification

---

## Error Handling

**If blueprint is incomplete**:
- Missing cost estimate → Use defaults ($50-150/month infrastructure)
- Missing sprint backlog → Estimate 8-12 weeks for MVP
- Missing complexity assessment → Mark all risks as "Medium"
- Missing SLOs → Use industry standards (99.9% uptime, <500ms latency)

**If blueprint is from `/architect:quick-spec`**:
- Warn user: "Quick-spec doesn't have enough detail. Run `/architect:blueprint` first."

---

## Examples

See [STAKEHOLDER_DOC_SPEC.md](../../STAKEHOLDER_DOC_SPEC.md) for detailed examples of each section.
