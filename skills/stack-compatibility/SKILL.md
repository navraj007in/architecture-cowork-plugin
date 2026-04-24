# Stack Compatibility Skill

Verifies that chosen technologies integrate well together. Prevents "I picked these tools and they don't work well together" regrets.

## When to Use

Use this skill to verify:
1. **Chosen tools work together** — React + Node + MongoDB = good?
2. **No hidden incompatibilities** — will I hit issues in production?
3. **Team can support it** — do we have expertise for this combo?
4. **Licenses compatible** — can we use these together commercially?
5. **Performance assumptions hold** — does this stack meet latency targets?

## Input

Provide tech stack selections:

```json
{
  "frontend": "React 18",
  "backend": "Node.js + Express",
  "database": "PostgreSQL",
  "cache": "Redis",
  "monitoring": "Datadog",
  "deployment": "Docker + Kubernetes",
  "auth": "Clerk",
  "cdn": "Cloudflare",
  "search": "Elasticsearch"
}
```

## Output

A compatibility report:

```json
{
  "overall_compatibility": 0.95,    // 0-1.0: how well do these work together?
  "green_flags": [
    "React + Node.js very common (300k+ GitHub projects)",
    "PostgreSQL + Redis standard caching pattern",
    "Clerk supports Node.js OAuth natively",
    "All chosen tools have mature Docker support"
  ],
  "yellow_flags": [
    "Elasticsearch adds operational complexity (requires 8GB RAM minimum)",
    "Datadog cost can spike with high cardinality metrics",
    "Kubernetes requires DevOps expertise (no junior-friendly)"
  ],
  "red_flags": [
    "None detected"
  ],
  "known_issues": [
    {
      "tools": "React + Node.js",
      "issue": "Build times can exceed 30s with large codebases",
      "mitigation": "Use cache busting, incremental builds, esbuild"
    }
  ],
  "performance_assumptions": {
    "api_latency": "200-500ms p99 (React hydration + Express processing)",
    "database_latency": "<50ms (PostgreSQL local)",
    "cache_hit_rate": "85% (typical for Redis with proper TTLs)",
    "combined_p99": "~500ms (acceptable for web app)"
  },
  "team_requirements": {
    "required_roles": ["Full-stack engineer", "DevOps/Kubernetes specialist"],
    "required_skills": ["JavaScript/TypeScript", "SQL", "Docker", "Kubernetes basics"],
    "hiring_difficulty": "Medium (Node devs common, Kubernetes specialists rare)",
    "onboarding_weeks": 3
  },
  "license_compatibility": {
    "react": "MIT ✅",
    "express": "MIT ✅",
    "postgresql": "PostgreSQL License (open source) ✅",
    "redis": "Redis License (open source) ✅",
    "datadog": "Proprietary ✅ (no GPL conflicts)",
    "all_compatible": true
  },
  "risk_score": 0.1,  // 0-1.0: how risky is this stack?
  "recommendations": [
    "Stack is well-proven and compatible. Good choice for your constraints.",
    "Ensure DevOps person familiar with Kubernetes before going live.",
    "Monitor Datadog costs closely (can surprise at scale).",
    "Plan for React build time optimization in week 2-3."
  ]
}
```

## Compatibility Categories

### 1. Integration Compatibility

**Questions:**
- Do these tools have published integrations?
- Do they share common languages (both support Node.js APIs)?
- Are there known version conflicts?
- Do webhooks/APIs work well together?

**Example checks:**
```
React + Node.js: ✅ Perfect (same language, many libraries)
React + .NET: ⚠️ Possible (cross-language requires REST API)
PostgreSQL + Elasticsearch: ✅ Standard (data pipeline)
PostgreSQL + DynamoDB: ❌ Bad (different paradigms, hard to sync)
```

### 2. Operational Compatibility

**Questions:**
- Do these tools have similar operational complexity?
- Can one person manage both?
- Are there conflicts in deployment patterns?
- Do monitoring/logging systems work for both?

**Example combinations:**
```
Vercel (fully managed) + Railway (managed) + Neon (managed): ✅ Great
  → All fully managed, one dashboard, simple operations
  
Vercel + self-hosted Kubernetes + managed Neon: ⚠️ Mixed complexity
  → Frontend fully managed, backend complex, database managed
  → Operations person needs multi-cloud expertise
  
Vercel + Kubernetes + self-hosted PostgreSQL: ❌ Operational nightmare
  → Three different operational models
  → Likely 3 different people, hard to coordinate
```

### 3. Performance Compatibility

**Questions:**
- Do the latencies add up (each tool adds latency)?
- Does one slow tool bottleneck the whole system?
- Are there known performance gotchas?
- Can this stack meet your latency targets?

**Example paths:**
```
React (hydration 100ms) + Node.js (request 50ms) + PostgreSQL (query 20ms) = 170ms p99
  → Acceptable for most web apps

React (100ms) + Go (5ms) + PostgreSQL (20ms) = 125ms p99
  → Better for performance-critical apps

React (100ms) + Lambda (cold start 200ms) + DynamoDB (30ms) = 330ms p99
  → Too slow if sub-200ms required, okay for regular web app
```

### 4. Ecosystem Compatibility

**Questions:**
- Are there enough libraries/tools for this combo?
- Is the community large (can find help)?
- Are alternatives limited (vendor lock-in)?
- Will tools still be maintained in 5 years?

**Example ecosystems:**
```
Node.js + React: ✅ Huge (700k npm packages, thousands of examples)
Go + React: ⚠️ Medium (Go ecosystem smaller, but growing)
Python + React: ✅ Large (but less integrated than Node + React)
.NET + Vue: ⚠️ Small (fewer integrations, harder to find examples)
```

### 5. Licensing Compatibility

**Questions:**
- Can we use these together commercially?
- Are there GPL obligations?
- Do licenses conflict?
- Do we need commercial support licenses?

**Common issues:**
```
Open source MIT tools: ✅ Safe (can use commercially)
GPL tools: ⚠️ Risky (might require open-sourcing your code)
Proprietary + GPL: ❌ Conflict (usually illegal to combine)
Open source + commercial SaaS: ✅ Fine (add proprietary layer on top)
```

## Known Incompatibilities

### Hard Incompatibilities (won't work together)

| Combo | Problem | Alternative |
|-------|---------|-------------|
| **Go + slow database** | Go handles 100k req/sec but PostgreSQL does 1k/sec → bottleneck | Use DynamoDB (scales better with Go) or add caching layer |
| **Django + microservices** | Django is monolith, forces tight coupling | Use FastAPI instead (designed for APIs) |
| **Kubernetes + stateful database** | Kubernetes assumes stateless, databases are stateful → conflicts | Use managed database (AWS RDS) instead |
| **React SPA + SEO critical** | JavaScript rendering invisible to crawlers → SEO fails | Use Next.js (server-side rendering) |

### Soft Incompatibilities (work but harder)

| Combo | Issue | Mitigation |
|-------|-------|-----------|
| **Python + real-time** | Python slower than Go/Node → harder to do real-time | Add Go microservice for real-time, Python for main app |
| **Monolith + serverless functions** | Monolith always running, functions cold-start → inconsistent latency | Restructure to microservices first |
| **Elasticsearch + small data** | Elasticsearch overkill for <1M documents → waste money and ops time | Use PostgreSQL full-text search instead |
| **DynamoDB + complex queries** | DynamoDB limited query language → hard to build reports | Add data warehouse (Snowflake, BigQuery) |

## Performance Compatibility Matrix

```
Frontend         | Backend       | Database | Typical Latency
-----------------|---------------|----------|----------------
React (100ms)    | Node (50ms)   | Postgres (20ms) | 170ms p99 ✅
React (100ms)    | Node (50ms)   | MongoDB (30ms)  | 180ms p99 ✅
React (100ms)    | Go (5ms)      | Postgres (20ms) | 125ms p99 ✅
React (100ms)    | Python (100ms)| Postgres (20ms) | 220ms p99 ⚠️
React (100ms)    | Lambda (200ms)| Dynamo (30ms)   | 330ms p99 ⚠️
Vue (80ms)       | Go (5ms)      | Postgres (20ms) | 105ms p99 ✅✅
Vue (80ms)       | Node (50ms)   | Postgres (20ms) | 150ms p99 ✅

Legend:
✅ Good (< 200ms) — acceptable for most web apps
⚠️ Acceptable (200-500ms) — noticeable but OK
❌ Poor (> 500ms) — users will feel lag
✅✅ Great (< 100ms) — competitive advantage
```

## Skill-Based Compatibility

Does your team have expertise for this stack?

```
Stack: React + Node.js + PostgreSQL
Required skills: JavaScript/TypeScript, basic SQL, npm/GitHub
Required experience: Junior+ (can learn on job)
Hiring difficulty: Easy (highest job market demand)
Compatibility: ✅ Great for most teams

Stack: Go + React + Kubernetes + Elasticsearch
Required skills: Go, TypeScript, Docker, Kubernetes, bash scripting
Required experience: Senior+ (need production experience)
Hiring difficulty: Hard (Go specialists rare)
Compatibility: ⚠️ Need experienced team or hire consultants

Stack: Python + React + FastAPI + PostgreSQL
Required skills: Python, TypeScript, SQL, async/await patterns
Required experience: Mid-level+ (Python async is tricky)
Hiring difficulty: Medium (Python common, but not as much as JS)
Compatibility: ✅ Good for teams with Python background
```

## Compatibility Scoring Algorithm

```
score = 0.0

// Integration compatibility (0-0.25)
if has_published_integrations:
  score += 0.15
if same_primary_language:
  score += 0.10

// Operational compatibility (0-0.25)
if both_fully_managed:
  score += 0.15
elif both_self_hosted:
  score += 0.10  // consistent but harder
elif mixed:
  score += 0.05  // harder to manage

if no_operational_conflicts:
  score += 0.10

// Performance compatibility (0-0.25)
if latencies_sum_to_target:
  score += 0.25
elif sum_within_10_percent:
  score += 0.20
elif sum_within_25_percent:
  score += 0.10
else:
  score += 0.0  // too slow

// Ecosystem compatibility (0-0.15)
if large_community:
  score += 0.10
if well_maintained:
  score += 0.05

// Licensing (0-0.10)
if all_compatible:
  score += 0.10
elif minor_issues:
  score += 0.05
else:
  score += 0.0  // can't use together

// Team skill match (0-0.10)
if team_has_experience:
  score += 0.10
elif similar_to_existing_skills:
  score += 0.05
else:
  score += 0.0  // hiring/training burden

return min(score, 1.0)
```

**Interpretation:**
- **0.9-1.0:** Excellent compatibility, go with this stack
- **0.7-0.9:** Good compatibility, minor considerations
- **0.5-0.7:** Acceptable but has trade-offs, understand them
- **<0.5:** Poor compatibility, reconsider choices

## Usage in Commands

### In `/architect:recommend-stack`

```pseudo
// After recommending 3 stacks:
for each recommended_stack:
  compatibility_score = check_compatibility(stack)
  if score < 0.7:
    add warning: "This stack has compatibility concerns"
    list yellow_flags
```

### New command: `/architect:check-stack-compatibility`

```
/architect:check-stack-compatibility [--stack-file stack.json]
→ Detailed compatibility report for your chosen stack
```

### In `/architect:scaffold`

```pseudo
// Before generating code:
check_compatibility(chosen_stack)
if red_flags:
  ask user: "This stack has known issues. Continue anyway?"
```

## Real-World Compatibility Examples

### Example 1: SaaS MVP (Good Compatibility)

```
Stack: React + Node.js + PostgreSQL + Vercel + Clerk
Score: 0.95 ✅

Green flags:
- React + Node.js industry standard (99,000+ GitHub projects)
- PostgreSQL + Node has mature libraries (Prisma, Knex)
- Vercel + Node native integration (best possible)
- Clerk supports Node.js OAuth natively
- All tools MIT/Apache licensed

Yellow flags: None

Result: This is the "default correct" stack for most SaaS companies
```

### Example 2: High-Performance API (Good Compatibility)

```
Stack: Go + React + DynamoDB + Lambda + Datadog
Score: 0.88 ✅

Green flags:
- Go + DynamoDB excellent fit (both designed for scale)
- Lambda + DynamoDB native AWS integration
- Datadog supports both Go and Lambda monitoring

Yellow flags:
- Go + DynamoDB harder hiring (Go specialists rare)
- React + Lambda cold starts (API might be slow)
- Team needs AWS expertise (Kubernetes simpler in some ways)

Result: Good for e-commerce/real-time, but requires experienced team
```

### Example 3: Data App (Some Compatibility Issues)

```
Stack: Python + React + PostgreSQL + Airflow + Spark
Score: 0.72 ⚠️

Green flags:
- Python + Airflow natural fit (both Python)
- Spark + PostgreSQL standard data pipeline

Yellow flags:
- Airflow operationally complex (needs dedicated DevOps person)
- Spark cold starts slow (not ideal for real-time)
- Team needs: Python devs + data engineers + DevOps → 3+ people

Red flags: None

Result: Good for data companies, but higher operational burden
```

### Example 4: Incompatible Choices (Poor Compatibility)

```
Stack: Java + Go (two backends) + React + 3 databases (PostgreSQL + MongoDB + DynamoDB)
Score: 0.45 ❌

Problems:
- Java + Go requires two teams (hard to coordinate)
- 3 databases create data sync nightmare
- Operational complexity extremely high (3 different DB types)
- Hiring: need Java + Go specialists (tiny overlap)
- Team structure breaks (8+ people needed)

Recommendation: Simplify to one backend language (Node or Go)
```

## Related Skills

- `constraint-solver/` — picks stack that fits constraints
- `blueprint-variants/` — generates architecture for chosen stack
- `cost-optimizer/` — estimates costs for different stack combos
