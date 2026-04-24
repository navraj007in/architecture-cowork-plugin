---
description: Recommend optimal tech stacks based on project type, team expertise, budget, and timeline
---

# /architect:recommend-stack

Analyzes project requirements and recommends 3 tech stacks tailored to your constraints. Instead of "should we use Node or Go?", users get: "These 3 stacks fit your project. Here's what each is good at."

## Trigger

```
/architect:recommend-stack
/architect:recommend-stack [--project-type web-app|api|mobile|data-pipeline|hybrid]
/architect:recommend-stack [--compare stack1 stack2]  # detailed comparison
/architect:recommend-stack [--simulate-swap old new]  # cost/effort to switch
```

## Purpose

Choosing a tech stack is hard because every choice has trade-offs:
- Node.js: Easy to hire, good for startups, not ideal for CPU-intensive work
- Go: Fast, compiled, great for systems, harder to hire
- Python: Best for ML/data, slow for high-throughput, good hiring pool
- Rust: Blazingly fast, steep learning curve, small community

**This command ends the guessing.** It recommends 3 stacks that fit YOUR project, not abstract "best" stacks.

## Input

**Optional (interactive if not provided):**
```json
{
  "project_type": "web-app",           // web-app | api | mobile | data-pipeline | hybrid
  "team_expertise": "startup",          // startup | growing | mature
  "budget_monthly": 5000,               // dollars/month
  "timeline_weeks": 8,                  // weeks to launch
  "performance_critical": false,        // true if <100ms latency required
  "scale_target": 100000,               // expected DAU at launch
  "compliance_required": [],            // GDPR | SOC2 | HIPAA | etc.
  "team_size": 3                        // engineers available
}
```

## Output

**1. `architecture-output/stack-recommendations.md`**

```markdown
# Tech Stack Recommendations

**Generated:** 2026-04-24  
**Project:** my-startup (web app)  
**Constraints:** 3 engineers, $5k/mo, 8 weeks, 100k DAU target

---

## Quick Comparison

| Stack | Language | Backend | Database | Cost | Complexity | Hire Difficulty | Recommended For |
|-------|----------|---------|----------|------|-----------|-----------------|---|
| **Modern Web** | TypeScript | Next.js | PostgreSQL | Low | Medium | Easy | ✅ 95% of web apps |
| Full-Stack Python | Python | FastAPI | PostgreSQL | Medium | Medium | Medium | Data-heavy apps, AI integration |
| Go + React | Go | Echo | PostgreSQL | Low | High | Hard | High-throughput APIs |

---

## Stack 1: Modern Web (RECOMMENDED) ✅

**Frontend:** Next.js 14 with React  
**Backend:** Node.js + Express (or Next.js API routes)  
**Database:** PostgreSQL  
**Cache:** Redis  
**Deployment:** Vercel (frontend) + Railway (backend)

### Why Recommended
- **Sweet spot:** balances ease (hire developers), power (scales to 100k+ users), cost (cheap hosting)
- **Ecosystem:** thousands of libraries, tons of tutorials, easy to find answers
- **Learning curve:** JavaScript everywhere = one language for full-stack
- **Job market:** highest demand (easiest to hire replacements)
- **Scalability:** proven at scale (Netflix, Uber, Airbnb started here)

### Team Fit
- **Startup engineers:** ✅ Comfortable (familiar patterns)
- **Hiring:** ✅ Easy (highest demand language)
- **Ramp time:** 2-3 weeks for team to be productive
- **Expertise needed:** JavaScript, React basics, SQL basics

### Cost Breakdown
```
Frontend (Vercel): $20/mo
Backend (Railway): $1,200/mo
Database (PostgreSQL): $1,800/mo
Cache (Redis): $200/mo
Monitoring: $300/mo
Total: ~$3,500/mo (fits $5k budget)
```

### Scalability Path
```
Current: 100k DAU ($3.5k/mo)
  ↓ (add caching)
Scale to 500k DAU: $5k/mo (same stack, more server)
  ↓ (add read replicas)
Scale to 1M DAU: $8k/mo (proven, no rearchitect needed)
```

### Pros
- ✅ Largest job market (easiest hiring)
- ✅ Tons of libraries and frameworks
- ✅ Cheap hosting (competitive market)
- ✅ Fast development (good DX)
- ✅ Scales to millions of users
- ✅ Mature ecosystem (battle-tested)

### Cons
- ❌ Slower than Go/Rust (but: 99% of apps don't need that)
- ❌ Memory usage higher than Go
- ❌ Not ideal for CPU-intensive (math, ML)
- ❌ Slightly harder to debug than Go

### When to Choose
- Building a web app (form-heavy CRUD)
- Team knows JavaScript
- Want to launch fast
- Hiring is important (not just engineering, need flexibility)
- 95% of web apps, this is the right choice

### When NOT to Choose
- Processing billions of events/second (choose Go)
- ML/AI heavy (choose Python)
- Real-time multiplayer (choose Go for better scaling)
- Embedded systems (choose Rust/C)

---

## Stack 2: Full-Stack Python

**Frontend:** React (JavaScript)  
**Backend:** FastAPI (Python)  
**Database:** PostgreSQL  
**Cache:** Redis  
**Data Processing:** Pandas + NumPy + Scikit-learn  
**Deployment:** AWS Lambda + RDS

### Why Python
- **Data science:** if your app is data/ML heavy, Python is standard
- **Readable:** fastest to write, easiest to onboard new devs
- **Libraries:** 300k packages on PyPI, best-in-class for ML/data
- **Learning curve:** easiest to learn (great for startups with mixed skill levels)

### When to Choose
- Data analysis or ML is core feature
- Team has Python expertise
- Analytics/reporting is heavy lift
- Willing to trade performance for development speed
- Budget allows for more compute ($6-8k/mo for same perf as Node)

### Cost Impact
```
Same as Modern Web, but add:
  - Lambda compute: +$200/mo (less efficient than Railway Node)
  - ML libraries: +$500/mo (GPU instances for training)
Total: ~$4.2k/mo (slightly more than Node for same perf)
```

### Scalability Limits
- **Max DAU on single server:** 10k (Python slower)
- **Path to scale:** add worker processes, but need more servers
- **Cost at scale:** 2-3× more expensive than Go/Node at 1M DAU

### Hiring
- ⚠️ Medium difficulty
- Python devs common but fewer than JavaScript devs
- May need specialized data engineers

---

## Stack 3: Go + React

**Frontend:** React  
**Backend:** Go + Echo framework  
**Database:** PostgreSQL  
**Deployment:** Docker on Kubernetes  

### Why Go
- **Performance:** 10× faster than Node.js per server
- **Simplicity:** concurrency is easy (goroutines)
- **Binaries:** compiles to single executable (no dependency hell)
- **Scaling:** handles 100k requests/second on single server

### When to Choose
- Building high-throughput API (>10k req/sec)
- Real-time features (trading, collaboration)
- Microservices architecture
- Performance is competitive advantage
- Team comfortable with compiled languages

### When NOT to Choose
- Web app with lots of UI (React complexity)
- Team is JavaScript-focused (hiring harder)
- Budget tight ($2k/mo only works with Node, not Go infrastructure)
- Startup phase (speed to market more important than performance)

### Cost Impact
```
Lower compute cost (Go is efficient):
  - Backend (Kubernetes): $800/mo (instead of $1,200 for Node)
But requires DevOps expertise:
  - DevOps person: $8k/mo (or time from engineer)
Total: ~$4.5k/mo (similar to Node, but requires more expertise)
```

### Hiring Difficulty
- ⚠️ Hard (Go developers less common than JS/Python)
- ⚠️ Specialist skill (takes longer to ramp)
- ⚠️ Larger salary expectations (Go pays premium)

### Scalability
```
Current: 100k DAU on $800/mo compute (efficient!)
  ↓
Scale to 1M DAU: still ~$1.5k/mo (Go scales linearly)
Scale to 10M DAU: ~$3k/mo compute (Go is the winner here)

Go wins at extreme scale, but requires DevOps expertise
```

---

## Stack Comparison Table

| Dimension | Modern Web | Python | Go |
|---|---|---|---|
| **Languages** | JavaScript (TS) | Python + JavaScript | Go + JavaScript |
| **Learning curve** | Easy (JS consistent) | Easy (readable Python) | Medium (Go is different) |
| **Hiring** | Easiest | Medium | Hardest |
| **Development speed** | Fast | Fastest | Medium |
| **Performance** | Medium (200 req/sec) | Slow (50 req/sec) | Fast (1000 req/sec) |
| **Cost at 100k DAU** | $3.5k/mo | $4.2k/mo | $4.5k/mo |
| **Cost at 1M DAU** | $8k/mo | $20k/mo | $3k/mo |
| **Complexity** | Medium | Medium | High |
| **Scalability** | To 1M DAU | To 500k DAU | To 10M+ DAU |
| **ML/Data** | Okay | ✅ Best | Weak |
| **Real-time** | Okay | Weak | ✅ Best |
| **Job market** | Huge | Large | Small |
| **When to choose** | 95% of cases | Data-heavy apps | High-throughput APIs |

---

## Decision Tree

```
1. What's your primary concern?

   a) Launch fast, hire easily
      → Modern Web (JavaScript/TypeScript)
   
   b) Data/ML is core
      → Full-Stack Python
   
   c) Performance critical
      → Go + React

2. Does your team have expertise?
   
   a) JavaScript team
      → Modern Web (1-week ramp)
   
   b) Python team
      → Full-Stack Python (1-week ramp)
   
   c) No strong preference
      → Modern Web (best hiring market)
   
   d) Go specialists available
      → Go + React (but budget for devops)

3. Is budget primary constraint?

   a) Tight ($2-3k/mo)
      → Modern Web + serverless (cheapest)
   
   b) Comfortable ($4-6k/mo)
      → Modern Web (sweet spot)
   
   c) Scalability important ($10M+ DAU)
      → Go (scales cheapest at extreme scale)

→ Pick stack that wins the tiebreaker question
```

---

## Stack Swap Simulator

**Question:** "What if we switch from Node.js to Go later?"

**Effort to switch:**
- Database schema: ✅ Same (portable)
- API contracts: ⚠️ Must be compatible (doable)
- Frontend: ✅ Same (React works with any backend)
- Infrastructure: ❌ Completely different (1-2 weeks ramp)
- Total rework: 3-4 weeks development

**Cost to switch:**
- Development time: 2-3 engineers × 3 weeks = $15-20k
- DevOps setup: 1 engineer × 1 week = $5k
- Downtime risk: 1-2 days testing = $1-5k

**When worth it:**
- Only if scaling past 500k DAU (performance costs justify rework)
- Modern Web at 1M DAU costs $8k/mo
- Go at 1M DAU costs $3k/mo
- Savings: $5k/mo × 12 = $60k/year
- Payback period: 4-6 months (worth it if staying 1M+ long-term)

**Alternative:** Use Go from start if scaling expected in roadmap

---

## Compatibility Matrix: Can These Pieces Work Together?

```
Frontend Options:
  ✅ React
  ✅ Vue
  ✅ Svelte
  ❌ Angular (bulky, not recommended)

Backend + Database:
  ✅ Node + PostgreSQL
  ✅ Node + MongoDB
  ✅ Python + PostgreSQL
  ✅ Python + MongoDB
  ✅ Go + PostgreSQL
  ⚠️ Go + MongoDB (Go JSON handling okay, but not ideal)
  ❌ Java + PostgreSQL (old stack, harder to hire)

All combinations above work, but some are better optimized
```

---

## What NOT Recommended

### ❌ Java/Spring Boot
- Old ecosystem (harder to hire junior devs)
- Overkill complexity for startups
- Slower deployment (JVM startup time)
- Better for: enterprise internal tools only

### ❌ .NET Core
- Microsoft ecosystem lock-in
- Smaller community than Node/Python
- Better for: Windows-only enterprises

### ❌ Ruby on Rails
- Beautiful framework, but aging
- Community shrinking
- Better for: established Rails shops (don't switch)

### ❌ PHP
- Dying ecosystem (legacy only)
- Poor hiring market
- Better for: legacy WordPress sites only

---

## Behavioral Steps

### Step 1: Load project context
- If provided: read from input
- If not: ask user interactively:
  - What kind of project? (web app, API, etc.)
  - Team expertise? (what languages do you know?)
  - Budget? ($/month)
  - Timeline? (weeks to launch)
  - Performance critical?
  - Scale target?

### Step 2: Analyze constraints
- Call constraint-solver to check feasibility
- Identify which constraints matter most
- Flag constraint conflicts

### Step 3: Score stacks
For each well-known stack (Modern Web, Python, Go, etc.):
- Hiring ease: (0-10) based on job market
- Learning curve: (0-10) for your team
- Cost: calculate monthly burn
- Scalability: when does it hit limits?
- Compatibility: will recommended tools work together?
- Fit score: weighted average

### Step 4: Rank by fit
- Pick top 3 stacks by fit score
- Ensure diversity (don't recommend 3 JavaScript variants)
- Include one "safe" pick, one "ambitious" pick

### Step 5: Generate report
Output: `stack-recommendations.md` with:
- Quick comparison table
- Detailed breakdown for each stack
- Decision tree
- Compatibility matrix
- Swap simulator

### Step 6: Update activity log
```json
{"ts":"...","phase":"recommend-stack","outcome":"success","stacks_recommended":3,"recommended":"modern-web","summary":"Recommended Modern Web (JavaScript) for web app with 3 engineers, 8-week timeline, $5k budget"}
```

---

## Flags

### `--project-type TYPE`
Filter stacks by project type:
- `web-app` — frontend + backend (recommend Modern Web, Python)
- `api` — backend only (recommend Go, Python, Node)
- `mobile` — native mobile (Kotlin, Swift) (not in scope yet)
- `data-pipeline` — ETL/data processing (Python, Go)
- `hybrid` — web + API + data

### `--compare STACK1 STACK2`
Detailed comparison of two stacks:
```
/architect:recommend-stack --compare "modern-web" "go"
→ Shows exact trade-offs between Node.js and Go
```

### `--simulate-swap FROM TO`
Cost and effort to switch stacks:
```
/architect:recommend-stack --simulate-swap "node" "go"
→ Shows: 3-4 weeks effort, $15-20k cost, -$5k/mo at 1M DAU scale
```

---

## Related Commands

- `/architect:blueprint-variants` — architecture options based on constraints
- `/architect:cost-estimate` — detailed cost breakdown
- `/architect:stack-compatibility` — verify chosen tools integrate (Phase 3.2)
- `/architect:scaffold` — generate code for chosen stack
