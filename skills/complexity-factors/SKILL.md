---
name: complexity-factors
description: 10-factor weighted scoring methodology for assessing build difficulty. Includes factor definitions, scoring guides, and agent/hybrid adjustments. Use when assessing project complexity.
---

# Complexity Factors

A 10-factor scoring methodology for assessing how hard a product is to build. Use this to produce consistent, defensible complexity assessments.

---

## Scoring Scale

| Score | Label | Meaning |
|-------|-------|---------|
| 1-3 | **Simple** | Can be built by one developer using standard tools. Well-understood patterns. |
| 4-5 | **Moderate** | Requires careful planning. Some specialized knowledge needed. 1-2 developers. |
| 6-7 | **Advanced** | Significant complexity. Multiple specialized skills needed. Small team (2-4). |
| 8-10 | **Very Advanced** | Cutting-edge or highly complex. Large team, long timeline, high risk. |

---

## The 10 Factors (Standard App)

Score each factor 1-10, then calculate the weighted average.

| # | Factor | Weight | What It Measures |
|---|--------|--------|-----------------|
| 1 | **User Roles & Permissions** | 8% | How many user types, how complex is access control |
| 2 | **Frontend Complexity** | 10% | Number of screens, interactivity level, real-time needs |
| 3 | **Backend Architecture** | 12% | Number of services, communication patterns, async processing |
| 4 | **Data Model** | 10% | Number of entities, relationships, query complexity |
| 5 | **Integrations** | 12% | Number of third-party services, API complexity, webhook handling |
| 6 | **Authentication & Security** | 10% | Auth requirements, data sensitivity, compliance needs |
| 7 | **Infrastructure & Deployment** | 8% | Hosting complexity, scaling needs, CI/CD requirements |
| 8 | **Real-time Features** | 10% | WebSocket, SSE, live updates, collaborative editing |
| 9 | **AI/ML Components** | 12% | Agent complexity, model selection, fine-tuning needs |
| 10 | **Regulatory & Compliance** | 8% | GDPR, HIPAA, PCI-DSS, SOC 2, data residency |

**Total weight: 100%**

---

## Factor Scoring Guide

### 1. User Roles & Permissions (Weight: 8%)

| Score | Description |
|-------|-------------|
| 1-2 | Single user type, no permissions needed |
| 3-4 | 2-3 user types with basic role-based access |
| 5-6 | Multiple roles with granular permissions per resource |
| 7-8 | Multi-tenant with organization-level permissions |
| 9-10 | Complex permission trees, delegated admin, cross-org sharing |

### 2. Frontend Complexity (Weight: 10%)

| Score | Description |
|-------|-------------|
| 1-2 | Simple forms and lists, 3-5 pages |
| 3-4 | Moderate UI with 5-15 pages, basic interactivity |
| 5-6 | Complex UI with dashboards, charts, drag-and-drop |
| 7-8 | Rich interactive UI, real-time updates, complex state |
| 9-10 | Collaborative editor, canvas/drawing, complex animations |

### 3. Backend Architecture (Weight: 12%)

| Score | Description |
|-------|-------------|
| 1-2 | Single API server, CRUD operations |
| 3-4 | API server + background jobs, basic business logic |
| 5-6 | Multiple services, message queues, event-driven patterns |
| 7-8 | Microservices, complex orchestration, distributed transactions |
| 9-10 | Event sourcing, CQRS, saga patterns, custom protocols |

### 4. Data Model (Weight: 10%)

| Score | Description |
|-------|-------------|
| 1-2 | 3-5 simple entities, basic relationships |
| 3-4 | 5-15 entities, standard relationships, basic queries |
| 5-6 | 15-30 entities, complex relationships, aggregations |
| 7-8 | Multi-database strategy, data pipelines, migrations at scale |
| 9-10 | Graph relationships, time-series data, complex analytics |

### 5. Integrations (Weight: 12%)

| Score | Description |
|-------|-------------|
| 1-2 | 0-1 integrations, well-documented APIs |
| 3-4 | 2-4 integrations, standard REST APIs |
| 5-6 | 5-8 integrations, some with webhooks or OAuth |
| 7-8 | 8-15 integrations, custom protocols, data sync |
| 9-10 | 15+ integrations, legacy systems, bidirectional sync |

### 6. Authentication & Security (Weight: 10%)

| Score | Description |
|-------|-------------|
| 1-2 | Basic email/password login, no sensitive data |
| 3-4 | Social login, password reset, basic input validation |
| 5-6 | MFA, API keys, rate limiting, encrypted data at rest |
| 7-8 | SSO/SAML, audit logging, field-level encryption |
| 9-10 | Compliance-driven security (HIPAA, PCI), pen testing required |

### 7. Infrastructure & Deployment (Weight: 8%)

| Score | Description |
|-------|-------------|
| 1-2 | Single platform deploy (Vercel, Netlify), no scaling needs |
| 3-4 | Simple CI/CD, staging environment, basic monitoring |
| 5-6 | Multi-service deployment, auto-scaling, infrastructure as code |
| 7-8 | Multi-region, custom networking, Kubernetes |
| 9-10 | Multi-cloud, disaster recovery, zero-downtime deployments |

### 8. Real-time Features (Weight: 10%)

| Score | Description |
|-------|-------------|
| 1-2 | No real-time needs, standard request-response |
| 3-4 | Simple notifications or status updates (polling or SSE) |
| 5-6 | Live chat, real-time dashboards (WebSocket) |
| 7-8 | Collaborative editing, presence indicators, live cursors |
| 9-10 | Video/audio streaming, multiplayer, conflict resolution (CRDT) |

### 9. AI/ML Components (Weight: 12%)

| Score | Description |
|-------|-------------|
| 1-2 | No AI, or single API call to an LLM |
| 3-4 | Simple agent with 1-2 tools, basic RAG |
| 5-6 | Multi-tool agent, vector search, conversation memory |
| 7-8 | Multi-agent system, custom fine-tuning, evaluation pipeline |
| 9-10 | Custom model training, real-time ML inference, complex orchestration |

### 10. Regulatory & Compliance (Weight: 8%)

| Score | Description |
|-------|-------------|
| 1-2 | No regulatory requirements, general SaaS terms |
| 3-4 | Basic GDPR compliance (privacy policy, data deletion) |
| 5-6 | GDPR with right-to-erasure, cookie consent, data processing agreements |
| 7-8 | Industry-specific compliance (HIPAA, PCI-DSS), audit requirements |
| 9-10 | Multi-jurisdiction compliance, SOC 2, data residency requirements |

---

## Agent/Hybrid Project Adjustments

For projects with type `agent` or `hybrid`, factor 9 (AI/ML Components) gets additional weight. Adjust:

| Factor | Standard Weight | Agent/Hybrid Weight |
|--------|----------------|-------------------|
| AI/ML Components | 12% | 20% |
| Backend Architecture | 12% | 10% |
| Frontend Complexity | 10% | 6% |
| Real-time Features | 10% | 8% |

All other factors keep their standard weights. Re-normalize to 100%.

---

## Calculation

```
Overall Score = Σ (factor_score × factor_weight) for all 10 factors
```

### Example

| Factor | Score | Weight | Weighted |
|--------|-------|--------|----------|
| User Roles | 3 | 8% | 0.24 |
| Frontend | 5 | 10% | 0.50 |
| Backend | 4 | 12% | 0.48 |
| Data Model | 4 | 10% | 0.40 |
| Integrations | 6 | 12% | 0.72 |
| Auth & Security | 3 | 10% | 0.30 |
| Infrastructure | 2 | 8% | 0.16 |
| Real-time | 3 | 10% | 0.30 |
| AI/ML | 5 | 12% | 0.60 |
| Compliance | 2 | 8% | 0.16 |
| **Total** | | **100%** | **3.86 → 4 (Moderate)** |

---

## Output Format

When presenting a complexity assessment, **be comprehensive and thorough**:

### 1. Overall Score (REQUIRED)

**Format:**
```
Complexity: X.Y/10 — [Label]

[Label] = Simple (1-3) | Moderate (4-5) | Advanced (6-7) | Very Advanced (8-10)
```

**Show calculation explicitly:**
```
Weighted Overall: (score₁×weight₁ + score₂×weight₂ + ... + score₁₀×weight₁₀) / 100 = X.Y

Example: (3×8 + 5×10 + 4×12 + 4×10 + 6×12 + 3×10 + 2×8 + 3×10 + 5×12 + 2×8) / 100 = 3.86 → 4
```

### 2. 10-Factor Breakdown Table (MUST be comprehensive)

**Each factor MUST have detailed justification (2-3 sentences minimum):**

| # | Factor | Weight | Score | Justification |
|---|--------|--------|:-----:|---------------|
| 1 | User Roles & Permissions | 8% | X | **Why this score:** [Explain the specific roles and permission model]. **What makes it this complex:** [Reference specific requirements from the architecture]. **Impact on build:** [How this affects development effort]. |
| ... | ... | ... | ... | ... |

**Example of thorough justification:**
```
| 1 | User Roles & Permissions | 8% | 4 | **Why this score:** Three distinct roles (Admin, Member, Viewer) with workspace-scoped permissions. **What makes it this complex:** Requires Row Level Security policies in PostgreSQL for each table, plus UI permission checks. Not multi-tenant, so organization-level complexity is avoided. **Impact on build:** Adds 20-30% to auth setup time compared to single-role app; RLS policies require careful testing. |
```

**DO NOT use one-line justifications like:**
- ❌ "Simple CRUD operations" (too vague)
- ❌ "Standard REST API" (not specific)
- ❌ "Uses PostgreSQL" (states obvious)

**DO use specific, detailed justifications like:**
- ✅ "8 database tables with foreign key relationships and soft deletes. Requires migration strategy for position field (used for Kanban ordering). Indexes needed for workspace_id + created_at queries that power the activity feed."
- ✅ "WebSocket subscriptions for real-time task updates. Optimistic UI updates with conflict resolution when multiple users edit the same task. Requires careful state management to handle stale data on reconnection."

### 3. Risk Analysis (MANDATORY if any factors score 7+)

**For each high-risk factor (scored 7+), provide comprehensive analysis:**

**Format:**
```
⚠️ High Risk Factor: [Factor Name] (Score: X/10)

Why it scored high:
[Explain in 3-4 sentences what specific aspects of the requirements pushed this score to 7+. Reference concrete requirements from the architecture manifest.]

Specific risks this introduces:
- Risk 1: [Specific technical risk with probability and impact]
- Risk 2: [Development timeline risk with specific delay estimate]
- Risk 3: [Maintenance or scaling risk with quantified impact]
- Risk 4: [Integration or dependency risk]

Concrete mitigation strategies:
1. [Specific action] — Reduces risk by [X%] or [Y weeks], requires [effort estimate]
2. [Specific action] — [Measurable impact on risk]
3. [Specific action] — [Measurable impact on risk]

Estimated effort to mitigate:
- Total additional development time: [X hours/days/weeks]
- When to implement: [Pre-launch / Month 1 / After MVP]
- Who needs to do it: [Required skill level/role]
```

**Example:**
```
⚠️ High Risk Factor: Real-time Features (Score: 8/10)

Why it scored high:
The app requires WebSocket subscriptions for live Kanban board updates with drag-and-drop position changes. Multiple users can be viewing and editing the same board simultaneously, requiring conflict resolution. The optimistic UI updates must handle stale data when a user reconnects after network interruption. This goes beyond simple notifications into collaborative editing territory.

Specific risks this introduces:
- Race conditions: 60% chance of position conflicts if 3+ users drag tasks simultaneously → users see tasks jump around or disappear
- Stale state risk: 40% chance of showing outdated task status after reconnection → users make decisions on wrong data
- Performance degradation: WebSocket connections at 500+ concurrent users may hit Supabase Realtime limits → $25/mo tier supports ~500, need Team tier ($599/mo) beyond that
- Development delays: First implementation attempt will likely have bugs → add 2-3 weeks for testing and edge case handling

Concrete mitigation strategies:
1. Use battle-tested library (@supabase/realtime-js with built-in reconnection) — Reduces implementation risk by 70%, costs 0 extra (already included), saves 1-2 weeks vs custom WebSocket
2. Implement position debouncing (batch updates every 300ms) — Reduces race conditions by 80%, adds 8 hours development, minimal UX impact
3. Always refetch board state on reconnection — Eliminates stale state risk, adds 4 hours development, costs ~100ms on reconnect (acceptable)
4. Add optimistic update rollback on conflict — Reduces UX confusion by 90%, adds 1-2 days development
5. Load test with 100 simulated concurrent users before launch — Identifies scaling issues early, costs 1 day testing

Estimated effort to mitigate:
- Total additional development time: 1.5-2 weeks on top of base real-time implementation
- When to implement: During sprint 2 (real-time sprint) — don't defer
- Who needs to do it: Developer with WebSocket/real-time experience (senior or mid with guidance)
```

### 4. Simpler Alternatives (MANDATORY if overall score > 6)

**When complexity is high, suggest 2-3 specific ways to reduce it:**

**Format for each alternative:**
```
Alternative #X: [Short descriptive name]

What to remove or simplify:
- [Specific feature to cut or simplify]
- [Specific feature to cut or simplify]
- [Specific feature to cut or simplify]

New projected complexity score:
- Before: X.Y/10 ([Label])
- After: Z.W/10 ([Label])
- Reduction: ΔX.Y points

Which factors improve:
| Factor | Before | After | Change |
|--------|--------|-------|--------|
| [Name] | X | Y | -Z |
| [Name] | X | Y | -Z |

Trade-offs (what you lose):
- [Business impact of removing feature 1]
- [Business impact of removing feature 2]
- [User experience impact]
- [Competitive disadvantage, if any]

Effort savings:
- Development time: [X weeks → Y weeks, saves Z weeks]
- Cost savings: $[Amount] (based on [hourly rate assumption])
- Time to market: [X% faster]

Recommendation:
[When this alternative makes sense vs when to stick with original plan]
```

**Example:**
```
Alternative #1: Polling Instead of Real-Time WebSockets

What to remove or simplify:
- Remove WebSocket subscriptions for live board updates
- Replace with 5-second polling for task changes
- Keep immediate optimistic updates (feels real-time to current user)
- Other users see changes within 5 seconds instead of instantly

New projected complexity score:
- Before: 6.8/10 (Advanced)
- After: 5.2/10 (Moderate)
- Reduction: 1.6 points

Which factors improve:
| Factor | Before | After | Change |
|--------|--------|-------|--------|
| Real-time Features | 8 | 4 | -4 (biggest impact) |
| Backend Architecture | 6 | 5 | -1 (simpler server) |
| Infrastructure | 5 | 4 | -1 (fewer moving parts) |

Trade-offs (what you lose):
- Collaboration UX: Users don't see each other's changes instantly (5s delay vs real-time)
- Server load: Increased HTTP requests (5-10x more than WebSocket), but still manageable at 500 users
- Battery/data: Mobile users consume more data and battery due to polling
- Competitive weakness: Many modern project tools (Linear, Notion) have real-time updates

Effort savings:
- Development time: 12 weeks → 9 weeks (saves 3 weeks on real-time complexity)
- Cost savings: $12,000-18,000 (based on contractor at $100-150/hr)
- Time to market: 25% faster

Recommendation:
Use this alternative if:
- Time to market is critical (need to launch in <3 months)
- Budget is constrained (<$50K total)
- Target users typically work solo or async (5s delay doesn't matter)
- Team lacks real-time/WebSocket expertise

Stick with WebSockets if:
- Real-time collaboration is a core value proposition
- Competing with tools like Linear, Notion, or Monday
- Have budget and timeline for proper implementation
- Planning to scale to 5K+ users (polling becomes expensive)
```

### 5. Build Path Recommendation (REQUIRED)

**Based on complexity score, provide specific build path options:**

**Format:**
```
Recommended Build Path: [Primary option]

Score X.Y/10 ([Label]) suggests:

Option A: [Recommended approach] ⭐
- Who: [Developer level/team size]
- Timeline: [Duration range]
- Cost: $[Range]
- Tools: [Specific stack/frameworks]
- Risk: [Low/Medium/High]
- Best for: [When this makes sense]

Option B: [Alternative approach]
- Who: [Developer level/team size]
- Timeline: [Duration range]
- Cost: $[Range]
- Tools: [Specific stack/frameworks]
- Risk: [Low/Medium/High]
- Best for: [When this makes sense]

Option C: [Another alternative]
- Who: [Developer level/team size]
- Timeline: [Duration range]
- Cost: $[Range]
- Tools: [Specific stack/frameworks]
- Risk: [Low/Medium/High]
- Best for: [When this makes sense]

⚠️ NOT Recommended: [Approaches to avoid]
- [Why certain approaches won't work for this complexity level]
```

**Guidelines by complexity score:**

**Simple (1-3):**
```
Option A: AI Builder Tools ⭐
- Who: Non-technical founder or junior developer
- Timeline: 1-3 weeks
- Cost: $0-5K (mostly tool subscriptions)
- Tools: Cursor AI, v0.dev, Bolt.new, Replit Agent
- Risk: Low — well-trodden path, lots of examples
- Best for: MVPs, internal tools, validating idea quickly

Option B: No-Code Platforms
- Who: Non-technical founder
- Timeline: 1-2 weeks
- Cost: $0-2K (platform fees)
- Tools: Bubble, Webflow, Softr, Glide
- Risk: Very Low — no code to maintain
- Best for: Non-technical teams, tight budget, need to pivot quickly

Option C: Solo Junior Developer
- Who: 1 junior dev with mentorship
- Timeline: 4-8 weeks
- Cost: $8K-25K
- Tools: Next.js + Supabase + shadcn/ui (tutorial-friendly stack)
- Risk: Medium — may need senior code review
- Best for: Learning opportunity, have senior available for review

⚠️ NOT Recommended: Agency ($50K+) — severe overkill for simple project
```

**Moderate (4-5):**
```
Option A: Experienced Solo Developer ⭐
- Who: 1 senior full-stack developer
- Timeline: 8-16 weeks
- Cost: $30K-80K (contractor rates)
- Tools: Modern full-stack framework (Next.js, SvelteKit, etc.) + managed services
- Risk: Medium — single point of failure, but manageable scope
- Best for: Clear requirements, founder can provide quick feedback

Option B: Small Team (2 developers)
- Who: 1 full-stack + 1 specialist (frontend or backend focus)
- Timeline: 6-12 weeks
- Cost: $50K-120K
- Tools: Same as Option A, with better division of labor
- Risk: Low-Medium — knowledge sharing, faster delivery
- Best for: Tight timeline, need specialist skills (design-heavy or complex backend)

Option C: Freelance Agency
- Who: Small agency (2-4 people)
- Timeline: 8-12 weeks
- Cost: $60K-150K
- Tools: Agency's preferred stack
- Risk: Low — experienced team, proven process
- Best for: First-time founders who want managed delivery

⚠️ NOT Recommended:
- AI builders alone — too complex for fully automated build
- Junior-only team — needs senior oversight for quality
- Big agency — $200K+ is overkill for moderate complexity
```

**Advanced (6-7):**
```
Option A: Focused Development Team ⭐
- Who: 2-3 developers (1 senior + 1-2 mid-level)
- Timeline: 12-24 weeks
- Cost: $100K-250K
- Tools: Production-grade stack with observability (Sentry, Datadog)
- Risk: Medium — complex enough to need active management
- Best for: Funded startup, clear product-market fit signal

Option B: Development Agency
- Who: Agency team (3-5 people: dev + design + PM)
- Timeline: 12-20 weeks
- Cost: $150K-350K
- Tools: Agency's battle-tested stack
- Risk: Low-Medium — managed process, design included
- Best for: Non-technical founders, need full-service

Option C: Staged Delivery (MVP → Full)
- Who: Start with 1-2 devs, expand to 3-4 after MVP
- Timeline: 8 weeks MVP + 16 weeks full build
- Cost: $50K MVP + $100K-200K full = $150K-250K total
- Tools: Choose stack that scales (avoid cutting corners)
- Risk: Medium — longer total timeline, but validates before full investment
- Best for: Uncertain product-market fit, want to validate before full build

⚠️ NOT Recommended:
- Solo developer — too much for one person, high burnout risk
- AI builders — not sophisticated enough for advanced features
- Offshore-only team without US PM — coordination overhead kills timeline
```

**Very Advanced (8-10):**
```
Option A: Dedicated Product Team ⭐
- Who: 4-6 developers + 1 PM + 1 designer
- Timeline: 24-40 weeks (6-10 months)
- Cost: $300K-800K
- Tools: Enterprise-grade stack with full observability, staging environments, comprehensive testing
- Risk: Medium-High — manage like a startup, not a project
- Best for: Well-funded startup, proven market, long-term product

Option B: Specialized Agency
- Who: Agency with specific domain expertise (e.g., healthcare, fintech, AI)
- Timeline: 24-36 weeks
- Cost: $400K-1M+
- Tools: Compliance-ready stack for your industry
- Risk: Medium — higher cost but expertise included
- Best for: Regulated industries, need compliance expertise

Option C: Phased Delivery with External + Internal
- Who: Start with agency (12 weeks), transition to internal team (ongoing)
- Timeline: 12 weeks agency MVP + ongoing internal development
- Cost: $200K agency + $500K-1M internal team (first year) = $700K-1.2M
- Tools: Choose stack your internal team can maintain
- Risk: Medium — transition risk, but builds internal capability
- Best for: Series A+ startups building core product team

⚠️ NOT Recommended:
- Small team (<4 people) — will underestimate complexity and miss deadline
- AI builders or no-code — cannot handle this complexity level
- Fixed-price contract — scope will change, use time & materials
- Offshore without strong US-based tech lead — communication overhead is fatal at this complexity
```

### 6. Calculation Transparency (ALWAYS show)

**Always show the full calculation:**

```
Complexity Calculation:

Factor 1 (User Roles): score × weight = X × 8% = Y
Factor 2 (Frontend): score × weight = X × 10% = Y
Factor 3 (Backend): score × weight = X × 12% = Y
Factor 4 (Data Model): score × weight = X × 10% = Y
Factor 5 (Integrations): score × weight = X × 12% = Y
Factor 6 (Auth & Security): score × weight = X × 10% = Y
Factor 7 (Infrastructure): score × weight = X × 8% = Y
Factor 8 (Real-time): score × weight = X × 10% = Y
Factor 9 (AI/ML): score × weight = X × 12% = Y
Factor 10 (Compliance): score × weight = X × 8% = Y
                                          ─────────
Total weighted score:                     = Z.ZZ

Rounded to one decimal: Z.Z/10 — [Label]
```
