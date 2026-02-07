# Prescriptive Decision Framework

**Purpose**: Guide non-technical founders through all major technology decisions without creating decision fatigue. Make smart recommendations based on constraints, not preferences.

**Philosophy**: Ask about what they HAVE (team, budget, compliance needs), not what they WANT. Recommend based on risk reduction, hiring optimization, and cost optimization.

---

## Framework Structure

Each technology decision follows this pattern:

1. **Ask about constraints** — budget, team capability, compliance, scale expectations
2. **Make a prescriptive recommendation** — one clear path forward
3. **Explain business impact** — why this choice reduces risk/cost/time
4. **Provide alternatives** — when to consider something else
5. **Explain why NOT** — when to avoid certain options

---

## 1. Cloud Provider Selection

### Questions to Ask (constraints, not preferences)

- **Budget**: What's your monthly infrastructure budget? (< $100 | $100-500 | $500-2000 | > $2000)
- **Team**: Do you have DevOps/cloud engineers on your team? (Yes/No)
- **Compliance**: Do you have specific compliance requirements? (HIPAA, SOC 2, FedRAMP, GDPR, None)
- **Existing accounts**: Do you already have accounts with Azure, AWS, or GCP? (Yes/No, which one?)
- **Microsoft ecosystem**: Are you using Microsoft 365, Azure AD, or other Microsoft services? (Yes/No)

### Decision Tree

```
IF budget < $500/month AND team has no DevOps engineers:
  → RECOMMEND: Managed platform (Vercel/Railway/Render)
  → REASONING: "Zero DevOps work. Deploy with one command. Scales automatically. Much cheaper than hiring cloud expertise."
  → COST: $20-100/month for most MVPs
  → ALTERNATIVE: "If you need more control later, you can migrate to AWS/Azure in 6-12 months once you have revenue"

ELSE IF Microsoft 365 or Azure AD in use:
  → RECOMMEND: Azure
  → REASONING: "Single bill, single sign-on, existing vendor relationship. Less vendor sprawl = easier compliance."
  → COST: Similar to AWS but bundled discounts possible
  → ALTERNATIVE: "AWS has more third-party tools, but managing multiple vendors adds complexity you don't need yet"

ELSE IF compliance = HIPAA or healthcare:
  → RECOMMEND: AWS with compliance partner
  → REASONING: "Largest ecosystem of HIPAA-compliant services. More security consultants know AWS. Compliance auditors expect AWS."
  → COST: $500-2000/month base + compliance tooling
  → ALTERNATIVE: "Azure also supports HIPAA but fewer specialized healthcare tools"

ELSE IF team has AWS experience:
  → RECOMMEND: AWS
  → REASONING: "Your team already knows it. Learning new cloud = 2-3 months slower. Speed matters more than features at MVP stage."
  → COST: Varies by workload
  → ALTERNATIVE: "Multi-cloud adds 10-20% overhead. Only go there if you have specific needs."

ELSE IF team has Azure experience:
  → RECOMMEND: Azure
  → REASONING: "Your team already knows it. Speed beats features for MVP."

ELSE IF team has GCP experience:
  → RECOMMEND: GCP
  → REASONING: "Your team already knows it. Speed beats features for MVP."

ELSE (no DevOps team, no existing relationships, budget > $500):
  → RECOMMEND: AWS
  → REASONING: "Largest hiring pool. Most third-party tools support it first. Easiest to find help when stuck."
  → COST: Varies by workload
  → ALTERNATIVE: "If you need ML/AI features, consider GCP. If you're Microsoft-heavy, consider Azure."
```

### When to Avoid

- **Multi-cloud at MVP stage**: "Adds 10-20% complexity overhead. Only do this if you have regulatory requirements or specific technical needs. You can always add a second cloud later."
- **Self-managed Kubernetes**: "Unless you have dedicated DevOps engineers, this is expensive overkill. Use managed platforms (Vercel, Railway, Render) or managed Kubernetes (EKS, AKS, GKE) instead."
- **GCP without ML/data workloads**: "GCP excels at ML/BigQuery but has smaller ecosystem for standard web apps. Harder to hire for."

---

## 2. Tech Stack (Frontend/Backend)

### Questions to Ask

- **Team**: Do you have developers? If yes, what frameworks do they know? (React, Vue, Python, Ruby, Node.js, etc.)
- **AI integration**: Will you be integrating LLM/AI features? (Yes/No)
- **Real-time features**: Do you need real-time updates (chat, live dashboards, collaborative editing)? (Yes/No)
- **SEO requirements**: Is SEO critical for your business model? (Yes/No - e.g., content sites, marketplaces)

### Decision Tree

```
IF team has framework experience (React/Next, Vue/Nuxt, Svelte, etc.):
  → RECOMMEND: Their existing framework
  → REASONING: "Your team already knows it. Productivity on day 1. Learning new framework = 1-2 months slower."
  → CAVEAT: "Unless the framework is outdated (Angular.js, Backbone) — then recommend migration"

ELSE IF AI integration = Yes AND team = None or small:
  → RECOMMEND: Next.js (React) + Python backend (FastAPI)
  → REASONING: "Next.js has best AI SDK support (Vercel AI SDK). Python has all AI libraries (OpenAI, LangChain, transformers). Largest AI hiring pool."
  → COST: Free frameworks, hosting $20-200/month
  → ALTERNATIVE: "SvelteKit if performance is critical, but smaller AI library ecosystem"

ELSE IF SEO critical = Yes:
  → RECOMMEND: Next.js or Nuxt (meta framework with SSR)
  → REASONING: "Server-side rendering = better SEO. Meta frameworks handle routing, data fetching, optimization automatically."
  → ALTERNATIVE: "SvelteKit also supports SSR and is faster, but smaller ecosystem"

ELSE IF real-time features = Yes:
  → RECOMMEND: Next.js or SvelteKit (framework with good WebSocket/SSE support)
  → REASONING: "Need server-side rendering AND real-time. These frameworks make it easy."

ELSE IF team = None (will hire):
  → RECOMMEND: Next.js (React) + TypeScript
  → REASONING: "Largest hiring pool (React). TypeScript catches bugs before production. Most third-party components available."
  → COST: Free frameworks, hosting $20-200/month
  → ALTERNATIVE: "SvelteKit if you value performance over ecosystem, but 10x fewer developers available"

ELSE:
  → RECOMMEND: Next.js (React) + TypeScript
  → REASONING: "Default safe choice. Largest ecosystem. Easiest to hire for. Best documentation."
```

### When to Avoid

- **Bleeding-edge frameworks**: "Don't use frameworks released < 6 months ago unless your team is expert. Bugs, breaking changes, and missing libraries will slow you down."
- **Microservices at MVP**: "Single backend (monolith) is 3-5x faster to build. Only split into microservices when you have 5+ backend engineers."
- **GraphQL unless needed**: "REST is simpler. Only use GraphQL if you have 10+ API consumers with different data needs (mobile app, web app, partners)."

---

## 3. Database Selection

### Questions to Ask

- **Data structure**: Is your data highly relational (lots of connections between entities)? (Yes/No)
- **Scale expectations**: How many users in year 1? (< 1K | 1K-10K | 10K-100K | > 100K)
- **Search requirements**: Do you need full-text search, fuzzy matching, or advanced querying? (Yes/No)
- **Team experience**: Does your team have database expertise? If yes, which databases? (PostgreSQL, MySQL, MongoDB, etc.)

### Decision Tree

```
IF team has database experience (PostgreSQL, MongoDB, etc.):
  → RECOMMEND: Their existing database
  → REASONING: "Your team already knows it. Database choice rarely matters at MVP stage. Speed matters more."
  → CAVEAT: "Unless it's outdated (MySQL 5.x, MongoDB < 4.0) — then recommend upgrade"

ELSE IF data is highly relational (e-commerce, SaaS with complex permissions, multi-tenant):
  → RECOMMEND: PostgreSQL (managed: Supabase, Neon, or AWS RDS)
  → REASONING: "Handles complex queries. JSONB support for flexibility. Best free tiers (Supabase: 500MB, Neon: 0.5GB). Largest ecosystem."
  → COST: $0-25/month (free tier) → $25-100/month (production)
  → ALTERNATIVE: "MySQL if you need better write performance, but PostgreSQL is more feature-rich"

ELSE IF search is critical (content platform, marketplace, documentation):
  → RECOMMEND: PostgreSQL + Typesense (or Meilisearch, Algolia)
  → REASONING: "PostgreSQL for main data. Dedicated search engine for speed/relevance. Don't make one database do both jobs."
  → COST: PostgreSQL $0-25/month + Search $0-50/month
  → ALTERNATIVE: "Algolia is easiest but expensive at scale ($1/1000 searches after free tier)"

ELSE IF unstructured data (documents, varied schemas, rapid prototyping):
  → RECOMMEND: MongoDB Atlas (or Supabase PostgreSQL with JSONB)
  → REASONING: "MongoDB = flexible schema, easy for prototypes. BUT PostgreSQL JSONB gives you flexibility + relational power."
  → RECOMMENDATION: "Start with PostgreSQL. Use JSONB columns for unstructured data. Gives you both flexibility and structure."
  → COST: MongoDB M0 free tier (512MB) → $57/month (M10). Supabase free tier larger (500MB-1GB).

ELSE IF scale > 100K users in year 1:
  → RECOMMEND: PostgreSQL (managed: AWS RDS or Supabase)
  → REASONING: "Proven at scale. Read replicas. Connection pooling. Mature monitoring tools."
  → COST: $50-200/month with connection pooling (PgBouncer)

ELSE (default):
  → RECOMMEND: PostgreSQL (Supabase or Neon)
  → REASONING: "Best free tier. SQL + JSONB flexibility. Supabase includes auth, storage, real-time for free. Easiest to hire for."
  → COST: $0/month (free tier) → $25/month (pro tier)
```

### When to Avoid

- **MongoDB unless you truly need schema flexibility**: "PostgreSQL JSONB gives you 80% of MongoDB's flexibility + full SQL power. Only use MongoDB if you have genuinely unpredictable schemas or massive document storage."
- **DynamoDB at MVP stage**: "Complex pricing. Hard to predict costs. Steep learning curve. Only use if you're all-in on AWS and need single-digit millisecond latency at massive scale."
- **Self-hosted databases**: "Managing backups, security, scaling = full-time job. Use managed services (Supabase, Neon, RDS, Atlas) unless you have dedicated DevOps."

---

## 4. Authentication Provider

### Questions to Ask

- **Budget**: What's acceptable for auth? (Free tier only | < $50/month | < $200/month | No limit)
- **Features needed**: Do you need social login, magic links, MFA, or just email/password? (List which ones)
- **Scale expectations**: How many users in year 1? (< 1K | 1K-10K | 10K-50K | > 50K)
- **Compliance**: Do you need SOC 2, HIPAA, or enterprise compliance? (Yes/No)

### Decision Tree

```
IF budget = Free tier only AND scale < 10K users:
  → RECOMMEND: Supabase Auth (included with database) or Clerk
  → REASONING: "Supabase: included free with database. Clerk: best free tier (10K MAU). Both have great DX."
  → COST: $0/month (Supabase) or $0/month up to 10K users (Clerk)
  → ALTERNATIVE: "Firebase Auth if you're using Firebase for other things (50K MAU free)"

ELSE IF compliance = Yes (SOC 2, HIPAA, enterprise):
  → RECOMMEND: Auth0
  → REASONING: "Best compliance certifications. Enterprise SSO. Mature audit logs. Trusted by banks/healthcare."
  → COST: Free tier (7K MAU) → $240/month (Essentials) → Custom (Enterprise)
  → ALTERNATIVE: "AWS Cognito if you're all-in on AWS, but worse developer experience"

ELSE IF features = Advanced (passwordless, magic links, beautiful UI out-of-box):
  → RECOMMEND: Clerk
  → REASONING: "Best UI components. Fastest to implement. Great free tier (10K MAU). Feels modern."
  → COST: $0/month (10K MAU) → $25/month (Pro)
  → ALTERNATIVE: "Auth0 if you need more compliance features"

ELSE IF scale > 50K users expected:
  → RECOMMEND: Auth0 or build on Supabase
  → REASONING: "Auth0: proven at massive scale. Supabase: cheaper but less enterprise features. At 50K+ MAU, cost matters."
  → COST COMPARISON:
    - Auth0: ~$1,200/month at 50K MAU (Essentials tier)
    - Clerk: ~$800/month at 50K MAU (Pro tier)
    - Supabase: ~$25-100/month (included with database Pro tier)
  → DECISION: "If budget-constrained, Supabase. If enterprise features needed, Auth0."

ELSE (default: small-medium scale, standard features):
  → RECOMMEND: Clerk (if standalone auth) or Supabase Auth (if using Supabase database)
  → REASONING: "Clerk: best DX, great free tier, modern UI. Supabase: included with database, no extra service."
  → COST: $0-25/month
```

### When to Avoid

- **Building your own auth**: "Don't. Security is hard. Password hashing, session management, MFA, account recovery — all have subtle bugs. Use a service unless you have dedicated security engineers."
- **AWS Cognito unless you're AWS-heavy**: "Complex, confusing pricing. Poor developer experience. Only use if you're all-in on AWS and need tight Lambda integration."
- **Firebase Auth unless using Firebase ecosystem**: "Vendor lock-in. If you're not using Firestore/Functions, better options exist (Clerk, Supabase)."

---

## 5. Hosting & Deployment Pattern

### Questions to Ask

- **Backend type**: What kind of backend? (API server, background jobs, serverless functions, WebSocket server)
- **Team**: Do you have DevOps engineers? (Yes/No)
- **Budget**: Infrastructure budget? (< $100 | $100-500 | > $500)
- **Scale expectations**: Expected traffic in first 6 months? (< 10K requests/day | 10K-100K/day | > 100K/day)

### Decision Tree

```
IF team has no DevOps AND budget < $500:
  → RECOMMEND: Vercel (frontend + serverless API) or Railway (if need traditional server)
  → REASONING: "Zero DevOps. Git push = deploy. Auto-scaling. Preview deployments. Monitoring included."
  → COST: Vercel $0-20/month (Hobby), Railway $5-50/month
  → WHEN TO USE WHICH:
    - Vercel: If using Next.js/React and API is mostly serverless functions
    - Railway: If you need persistent servers (WebSockets, background jobs, databases)

ELSE IF backend = WebSocket server or real-time features:
  → RECOMMEND: Railway or Render
  → REASONING: "Vercel functions time out at 60s. Real-time needs persistent connections. Railway/Render support this."
  → COST: Railway $5-100/month, Render free tier (sleeps) → $7-100/month

ELSE IF backend = Background jobs (video processing, email sending, AI inference):
  → RECOMMEND: Railway (for persistent workers) or AWS Lambda (for event-driven)
  → REASONING: "Background jobs need to run longer than serverless limits. Railway = simple. Lambda = cheaper at scale but complex."
  → COST: Railway $20-200/month, Lambda pay-per-use ($0.20 per million requests)

ELSE IF scale > 100K requests/day:
  → RECOMMEND: AWS (ECS Fargate or Lambda) or Railway Pro
  → REASONING: "Managed platforms get expensive at scale. AWS gives more control + lower per-request cost."
  → COST: AWS $100-500/month (depends on usage), Railway $100-500/month

ELSE (default: standard web app, small-medium scale):
  → RECOMMEND: Vercel (if Next.js) or Render (if other framework)
  → REASONING: "Easiest deployment. Best DX. Free tier generous enough for MVP. Upgrade path when you need it."
  → COST: $0-20/month
```

### When to Avoid

- **Kubernetes at MVP stage**: "Unless you have 3+ DevOps engineers, don't. Managed platforms (Vercel, Railway, Render) are 10x easier."
- **AWS EC2 (bare servers) unless you have DevOps**: "You'll spend 20-30 hours/month on server management. Use Fargate (managed containers) or Lambda (serverless) instead."
- **Self-managed anything**: "Monitoring, logging, auto-scaling, security patches = full-time job. Use managed services."

---

## 6. File Storage

### Questions to Ask

- **File types**: What are you storing? (User uploads: images/video/documents | Static assets | Backups)
- **Volume**: Expected storage in first year? (< 10 GB | 10-100 GB | 100 GB - 1 TB | > 1 TB)
- **Access pattern**: Public (CDN-delivered) or private (authenticated access)?
- **Budget**: Storage budget? (< $10/month | $10-50/month | > $50/month)

### Decision Tree

```
IF file types = User uploads (images/video) AND volume < 100 GB:
  → RECOMMEND: Uploadthing (if Next.js) or Cloudflare R2
  → REASONING: "Uploadthing: easiest integration, free tier (2GB). R2: no egress fees (huge savings). Both CDN-backed."
  → COST: Uploadthing $0-20/month, R2 ~$1.50/100GB/month (no egress!)
  → ALTERNATIVE: "S3 if you're AWS-heavy, but watch egress costs ($90/TB)"

ELSE IF access = Public CDN delivery (images, videos on website):
  → RECOMMEND: Cloudflare R2
  → REASONING: "Zero egress fees. S3-compatible API. Built-in CDN. S3 charges $90/TB egress — R2 doesn't."
  → COST: $0.015/GB/month storage + $0 egress (S3 would be $90/TB egress)
  → COMPARISON: At 1TB storage + 5TB egress/month:
    - R2: $15/month
    - S3: $23/month storage + $450 egress = $473/month

ELSE IF access = Private (authenticated, time-limited URLs):
  → RECOMMEND: S3 (if AWS) or Cloudflare R2 with presigned URLs
  → REASONING: "Need presigned URLs for security. Both support this. R2 cheaper."
  → COST: R2 $0.015/GB/month, S3 $0.023/GB/month + egress

ELSE IF volume > 1 TB:
  → RECOMMEND: Cloudflare R2 or Wasabi
  → REASONING: "R2: no egress fees. Wasabi: flat pricing ($6/TB/month), predictable. S3 gets expensive fast."
  → COST COMPARISON at 5TB storage + 10TB egress:
    - R2: $75/month storage + $0 egress = $75
    - Wasabi: $30/month (flat)
    - S3: $115/month storage + $900 egress = $1,015

ELSE IF file types = Backups:
  → RECOMMEND: Cloudflare R2 or Backblaze B2
  → REASONING: "Cheapest storage. Backups accessed rarely, so egress doesn't matter. Backblaze slightly cheaper than R2."
  → COST: Backblaze $5/TB/month, R2 $15/TB/month

ELSE (default: small scale, user uploads):
  → RECOMMEND: Uploadthing (if Next.js) or Supabase Storage (if using Supabase)
  → REASONING: "Simplest setup. Uploadthing free tier (2GB). Supabase included with database."
  → COST: $0-10/month
```

### When to Avoid

- **S3 for high-egress workloads**: "Egress is $90/TB. If you're serving images/videos to users, R2 saves 95% on egress."
- **Self-hosted storage**: "Managing redundancy, backups, CDN = complex. Cloud storage is < $20/TB/month. Not worth the risk."

---

## 7. Email Service

### Questions to Ask

- **Volume**: Expected emails per month? (< 3K | 3K-10K | 10K-100K | > 100K)
- **Type**: Transactional (receipts, confirmations) or marketing (newsletters)? (Transactional | Marketing | Both)
- **Budget**: Email budget? (Free tier only | < $50/month | No limit)

### Decision Tree

```
IF volume < 3K/month AND type = Transactional:
  → RECOMMEND: Resend
  → REASONING: "Best developer experience. 3K emails/month free. Built for developers, not marketers."
  → COST: $0/month (3K emails) → $20/month (50K emails)
  → ALTERNATIVE: "Postmark if you value deliverability over DX (100 emails/month free)"

ELSE IF volume < 100/day AND type = Transactional:
  → RECOMMEND: SendGrid
  → REASONING: "100 emails/day free forever. Good enough for early MVP testing."
  → COST: $0/month (100/day) → $20/month (40K emails)

ELSE IF type = Marketing (newsletters, campaigns):
  → RECOMMEND: ConvertKit or Mailchimp
  → REASONING: "Purpose-built for marketing. Segmentation, campaigns, automation. Resend/SendGrid are for transactional only."
  → COST: ConvertKit $0 (1K subscribers) → $29/month (3K subscribers)

ELSE IF volume > 100K/month:
  → RECOMMEND: AWS SES + Postal (self-hosted) or SendGrid
  → REASONING: "SES = $0.10/1000 emails (cheapest at scale). But complex setup. SendGrid easier, more expensive."
  → COST COMPARISON at 500K emails/month:
    - SES: ~$50/month
    - SendGrid: ~$90/month
    - Resend: ~$150/month

ELSE (default: transactional, < 50K/month):
  → RECOMMEND: Resend
  → REASONING: "Best DX. React email templates. Generous free tier. API-first."
  → COST: $0-20/month
```

### When to Avoid

- **Sendgrid for low volume**: "100/day limit on free tier. Resend gives you 3K/month free. Better deal."
- **AWS SES at MVP stage**: "Complex setup (SMTP config, bounce handling, reputation monitoring). Use Resend/Postmark unless you're sending > 100K/month."
- **Marketing platforms (Mailchimp) for transactional email**: "Expensive. No API. Built for campaigns, not order confirmations."

---

## 8. Monitoring & Error Tracking

### Questions to Ask

- **Team size**: How many developers? (1-2 | 3-5 | > 5)
- **Budget**: Monitoring budget? (Free tier only | < $50/month | > $50/month)
- **Priorities**: What matters most? (Catching errors | Understanding user behavior | Performance monitoring)

### Decision Tree

```
IF budget = Free tier only:
  → RECOMMEND: Sentry (errors) + Vercel Analytics (if using Vercel) or PostHog (if need product analytics)
  → REASONING: "Sentry free: 5K errors/month. Vercel Analytics: free with Vercel. PostHog free: 1M events/month."
  → COST: $0/month
  → CAVEAT: "Free tiers enough for MVP. Upgrade when you hit limits."

ELSE IF priorities = Catching errors (crashes, exceptions):
  → RECOMMEND: Sentry
  → REASONING: "Best error tracking. Source maps. Stack traces. Integrates everywhere. Industry standard."
  → COST: $0 (5K errors/month) → $29/month (50K errors)

ELSE IF priorities = User behavior (analytics, funnels, retention):
  → RECOMMEND: PostHog
  → REASONING: "Product analytics + session replay + feature flags. All-in-one. Open source. Generous free tier."
  → COST: $0 (1M events/month) → Pay as you go
  → ALTERNATIVE: "Mixpanel or Amplitude if you need enterprise features, but expensive"

ELSE IF priorities = Performance (slow pages, API latency):
  → RECOMMEND: Vercel Analytics (if Vercel) or Datadog (if complex infrastructure)
  → REASONING: "Vercel Analytics: built-in, zero config. Datadog: full observability but expensive."
  → COST: Vercel $0-25/month, Datadog $0 (5 hosts) → $180+/month

ELSE IF team > 5 developers:
  → RECOMMEND: Sentry + PostHog + Datadog (or New Relic)
  → REASONING: "Need full observability: errors + analytics + performance. Worth the cost with bigger team."
  → COST: ~$100-500/month total

ELSE (default: small team, MVP stage):
  → RECOMMEND: Sentry (errors) + PostHog (analytics)
  → REASONING: "Covers 80% of needs. Free tiers generous. Easy to set up."
  → COST: $0-50/month
```

### When to Avoid

- **Datadog at MVP stage**: "Expensive ($180+/month). Overkill unless you have complex infrastructure (microservices, Kubernetes)."
- **Building custom error tracking**: "Don't. Sentry is free for 5K errors/month. Your time is worth more."
- **Google Analytics for product analytics**: "Built for marketing (page views), not product (user actions). Use PostHog or Mixpanel."

---

## Implementation in Architecture Methodology

These decision frameworks should replace preference-based questions in `architecture-methodology/SKILL.md`. Instead of asking "What do you prefer?", the methodology should:

1. **Ask constraint questions** (budget, team, compliance, scale)
2. **Run through decision tree** (follow the logic above)
3. **Make prescriptive recommendation** (one clear path)
4. **Explain business impact** (cost, risk, hiring, time)
5. **Offer alternatives** (when to consider something else)
6. **Provide escape hatch** (link to learn more if curious)

Example transformation:

**OLD**:
```
Question 6: Do you have a preferred tech stack?
```

**NEW**:
```
Question 6a: Do you have developers on your team? If yes, are they experienced with any specific frameworks or languages?

Question 6b: Will you be integrating LLM/AI features?

Question 6c: Is SEO critical for your business model?

[Run decision tree based on answers]

RECOMMENDATION:
"Based on your answers, I recommend Next.js (React) + TypeScript for these reasons:
- Largest hiring pool (React developers)
- Best AI library support (Vercel AI SDK, LangChain)
- Server-side rendering for SEO
- Free to use, hosting ~$20-100/month

You could also consider SvelteKit if performance is more important than ecosystem size, but React has 10x more developers available for hire."
```

This pattern repeats for cloud provider, database, auth, hosting, storage, email, and monitoring decisions.

---

## Output Format for Recommendations

Every recommendation should follow this format:

```markdown
## [Technology Category] Recommendation

**Recommended**: [Specific service/technology]

**Business reasoning**:
- [Business impact point 1 - cost, risk, hiring, or time]
- [Business impact point 2]
- [Business impact point 3]

**Cost**: [Monthly cost range with context]

**Alternative**: [When to consider alternative option]

**Don't use**: [What to avoid and why]
```

Example:

```markdown
## Cloud Provider Recommendation

**Recommended**: Managed platform (Vercel + Railway)

**Business reasoning**:
- Zero DevOps work needed — your team can focus on product, not infrastructure
- Deploy with one Git push — faster iteration, less time debugging deployments
- Scales automatically up to 100K users — no capacity planning needed
- Much cheaper than hiring cloud expertise ($50-200/month vs $120K/year engineer)

**Cost**: $20-100/month for typical MVP (Vercel $20/month + Railway $50/month)

**Alternative**: If you later need more control or hit 100K+ users, migrate to AWS. This is a common path. Start simple, upgrade when revenue justifies complexity.

**Don't use**: AWS/Azure/GCP at MVP stage unless you have DevOps engineers. You'll spend 30-40% of dev time on infrastructure instead of product.
```

---

## Next Steps

1. Update `architecture-methodology/SKILL.md` to integrate these decision frameworks
2. Add constraint-based questions instead of preference questions
3. Ensure all recommendations follow the output format above
4. Test with sample prompts to validate recommendations match decision trees
