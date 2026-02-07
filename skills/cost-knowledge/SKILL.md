---
name: cost-knowledge
description: Real pricing data for cloud compute, databases, LLM tokens, auth, payments, email, hosting, and monitoring services. Use when estimating infrastructure or operational costs.
---

# Cost Knowledge

Real pricing data for cloud infrastructure, databases, LLM tokens, and third-party services. Use this data to produce grounded cost estimates. When data may be stale, use web search to verify current pricing.

> **Last verified:** February 2026. Prices change — always present as approximate ranges and note that users should verify before committing.
>
> **Staleness note:** The pricing data in this skill is a snapshot. Cloud providers, LLM vendors, and SaaS tools update pricing regularly. When generating cost estimates, use web search (if available via MCP) to verify current pricing for the key services. If web search is unavailable, state that prices are approximate and recommend the user verify at the provider's pricing page before committing.

---

## Pricing Assumptions (CRITICAL)

**All pricing in this skill assumes the following unless explicitly noted otherwise:**

- **Region**: US East (N. Virginia) for AWS/Azure/GCP, US regions for other services
- **OS**: Linux for compute instances
- **Billing**: On-demand pricing (not reserved instances, spot instances, or annual contracts)
- **Currency**: USD, excludes taxes and VAT
- **Data transfer**: Excludes egress costs unless explicitly mentioned (egress can add 20-50% to costs)
- **Pricing date**: Snapshot from early 2025

**These assumptions can cause 10-30% variance from actual costs.**

When presenting pricing to users, ALWAYS:
1. Label costs as "planning estimates" or "approximate"
2. Mention region assumptions when relevant (e.g., "~$50/month in us-east-1")
3. Flag egress costs as additional where significant (S3, CloudFront, etc.)
4. Recommend verification at provider pricing pages before committing
5. Note that free tiers may require credit card verification or have time limits

---

## Cloud Compute

### AWS

| Service | Tier | Monthly Cost | Notes |
|---------|------|-------------|-------|
| EC2 t3.micro | 1 vCPU, 1 GB RAM | ~$8/mo | Free tier eligible (750 hrs/mo for 12 months) |
| EC2 t3.small | 1 vCPU, 2 GB RAM | ~$16/mo | Good for small APIs |
| EC2 t3.medium | 2 vCPU, 4 GB RAM | ~$32/mo | Standard API server |
| EC2 t3.large | 2 vCPU, 8 GB RAM | ~$63/mo | Medium workloads |
| ECS Fargate | Per vCPU + memory | ~$30-70/mo per task | Pay per use, no server management |
| Lambda | Per request + duration | $0 to ~$5/mo typical | 1M free requests/mo, great for low traffic |
| Lambda (high traffic) | 10M+ requests/mo | $20-100/mo | Scales well but costs add up |

### GCP

| Service | Tier | Monthly Cost | Notes |
|---------|------|-------------|-------|
| Cloud Run | Per request + vCPU-sec | $0 to ~$10/mo typical | Free tier: 2M requests/mo |
| Cloud Run (production) | Sustained traffic | $30-100/mo | Always-on min instances add cost |
| Compute Engine e2-micro | 0.25 vCPU, 1 GB | ~$7/mo | Free tier eligible |
| Compute Engine e2-small | 0.5 vCPU, 2 GB | ~$14/mo | |
| Cloud Functions | Per invocation | $0 to ~$5/mo | 2M free invocations/mo |

### Azure

| Service | Tier | Monthly Cost | Notes |
|---------|------|-------------|-------|
| App Service B1 | 1 core, 1.75 GB | ~$13/mo | Basic tier |
| App Service S1 | 1 core, 1.75 GB | ~$70/mo | Standard with auto-scale |
| Functions Consumption | Per execution | $0 to ~$5/mo | 1M free executions/mo |
| Container Apps | Per vCPU + memory | ~$30-60/mo | Similar to Cloud Run |

### Budget Hosting

| Service | Free Tier | Paid Tier | Notes |
|---------|-----------|-----------|-------|
| Vercel | Hobby (free) | Pro $20/mo | Best for Next.js |
| Netlify | Free | Pro $19/mo | Best for static + serverless |
| Railway | $5 trial credit | $5/mo + usage | Simple deploy from GitHub |
| Render | Free (sleeps) | $7/mo (always on) | Good for small APIs |
| Fly.io | 3 shared VMs free | $2-5/mo per VM | Edge deployment |

---

## Databases

| Service | Free Tier | Starter | Production | Notes |
|---------|-----------|---------|------------|-------|
| **Supabase** (PostgreSQL) | 500 MB, 2 projects | Pro $25/mo | Team $599/mo | Includes auth, storage, realtime |
| **Neon** (PostgreSQL) | 0.5 GB, 1 project | Launch $19/mo | Scale $69/mo | Serverless, branching |
| **PlanetScale** (MySQL) | 1 DB, 5 GB | Scaler $39/mo | Team $99/mo | Branching, no foreign keys |
| **MongoDB Atlas** | M0 free (512 MB) | M10 $57/mo | M30 $340/mo | Document database |
| **AWS RDS** (PostgreSQL) | db.t3.micro free 12mo | db.t3.micro ~$14/mo | db.t3.medium ~$50/mo | Self-managed |
| **Upstash Redis** | 10K cmds/day free | Pay-as-you-go | Pro $280/mo | Serverless Redis |
| **Redis Cloud** | 30 MB free | $7/mo | $60/mo+ | Managed Redis |
| **Pinecone** (Vector) | Free (100K vectors) | Starter $70/mo | Standard varies | Vector search |
| **Weaviate Cloud** | Free (sandbox) | $25/mo | Custom | Vector database |
| **Firestore** | 1 GB free | Pay-as-you-go | | Real-time, mobile-first |
| **Turso** (SQLite) | 9 GB, 500 DBs | Scaler $29/mo | | Edge SQLite |

---

## LLM Token Pricing

Prices per million tokens (MTok).

### Anthropic (Claude)

| Model | Input | Output | Best For |
|-------|-------|--------|----------|
| Haiku 3.5 | $0.80 | $4.00 | High-volume, simple tasks |
| Sonnet 4 | $3.00 | $15.00 | Balanced quality and cost |
| Opus 4 | $15.00 | $75.00 | Complex reasoning, code generation |

### OpenAI

| Model | Input | Output | Best For |
|-------|-------|--------|----------|
| GPT-4o | $2.50 | $10.00 | General purpose |
| GPT-4o-mini | $0.15 | $0.60 | High-volume, simple tasks |
| o1 | $15.00 | $60.00 | Complex reasoning |
| o3-mini | $1.10 | $4.40 | Reasoning, cost-efficient |

### Google

| Model | Input | Output | Best For |
|-------|-------|--------|----------|
| Gemini 2.0 Flash | $0.10 | $0.40 | Fast, cheap, high-volume |
| Gemini 2.0 Pro | $1.25 | $5.00 | Balanced quality |

### Others

| Provider/Model | Input | Output | Notes |
|----------------|-------|--------|-------|
| Mistral Large | $2.00 | $6.00 | Strong multilingual |
| Mistral Small | $0.10 | $0.30 | Very cheap |
| Groq (LLaMA 3 70B) | $0.59 | $0.79 | Ultra-fast inference |
| DeepSeek V3 | $0.27 | $1.10 | Competitive quality/price |

### Token Cost Estimation Method

To estimate monthly LLM costs:

1. **Estimate conversations per month** (e.g., 1,000)
2. **Estimate tokens per conversation**: input (~500-2,000) + output (~500-2,000)
3. **Calculate**: conversations x tokens x price per token
4. **Add overhead**: system prompts, tool calls, retries (+20-30%)

**Example:** 1,000 conversations/mo x 2,000 input + 1,000 output tokens per conversation using Sonnet:
- Input: 1,000 x 2,000 / 1M x $3.00 = $6.00
- Output: 1,000 x 1,000 / 1M x $15.00 = $15.00
- Overhead (25%): $5.25
- **Total: ~$26/mo**

---

## Auth Services

| Service | Free Tier | Paid Tier | Notes |
|---------|-----------|-----------|-------|
| **Auth0** | 25K MAU | Essentials $35/mo (500 MAU) | Enterprise-grade, complex setup |
| **Clerk** | 10K MAU | Pro $25/mo | Best DX, fast integration |
| **Supabase Auth** | Included with Supabase | Included | PostgreSQL row-level security |
| **Firebase Auth** | 50K MAU free | Pay-as-you-go | Google ecosystem |
| **NextAuth.js / Auth.js** | Free (self-hosted) | Free | DIY, more control, more work |
| **Kinde** | 10.5K MAU | $25/mo | Modern, growing |

## Payment Processors

| Service | Transaction Fee | Monthly Fee | Notes |
|---------|----------------|-------------|-------|
| **Stripe** | 2.9% + $0.30 | $0 | Industry standard, best API |
| **PayPal** | 2.99% + $0.49 | $0 | Consumer familiarity |
| **Paddle** | 5% + $0.50 | $0 | Merchant of record (handles tax) |
| **LemonSqueezy** | 5% + $0.50 | $0 | Merchant of record, simpler |
| **Gumroad** | 10% | $0 | Simplest, highest fee |

## Email & SMS

| Service | Free Tier | Paid Tier | Notes |
|---------|-----------|-----------|-------|
| **SendGrid** | 100 emails/day | Essentials $20/mo (50K/mo) | Industry standard |
| **Resend** | 3,000 emails/mo | Pro $20/mo | Modern API, React Email |
| **Postmark** | 100 emails/mo | $15/mo (10K/mo) | Best deliverability |
| **AWS SES** | 3,000/mo free (from EC2) | $0.10/1,000 emails | Cheapest at scale |
| **Twilio SMS** | Trial credits | $0.0079/msg (US) | Most popular SMS API |
| **Vonage SMS** | Trial credits | $0.0068/msg (US) | Twilio alternative |

## Monitoring & Error Tracking

| Service | Free Tier | Paid Tier | Notes |
|---------|-----------|-----------|-------|
| **Sentry** | 5K errors/mo | Team $26/mo | Error tracking standard |
| **Datadog** | 5 hosts | Pro $15/host/mo | Full observability |
| **PostHog** | 1M events/mo | Pay-as-you-go | Product analytics + session replay |
| **LogTail (Better Stack)** | 1 GB/mo | $24/mo | Log management |
| **Grafana Cloud** | 10K metrics, 50 GB logs | Pro $29/mo | Open-source ecosystem |

## Storage & CDN

| Service | Free Tier | Paid Tier | Notes |
|---------|-----------|-----------|-------|
| **AWS S3** | 5 GB (12 months) | ~$0.023/GB/mo | Standard object storage |
| **Cloudflare R2** | 10 GB + 10M reads/mo | $0.015/GB/mo | No egress fees |
| **Google Cloud Storage** | 5 GB | ~$0.020/GB/mo | |
| **Cloudflare CDN** | Free | Pro $20/mo | Best free CDN |
| **CloudFront** | 1 TB/mo (12 months) | ~$0.085/GB | AWS ecosystem |
| **Uploadthing** | 2 GB free | $10/mo | Simple file uploads for Next.js |

---

## Cost Presentation Rules

When presenting cost estimates, **be thorough and comprehensive**:

### 1. Infrastructure & Service Breakdown (MUST be detailed)

**Format as a comprehensive table listing EVERY service:**

| Category | Service | Low (Free Tiers) | Medium (Starter) | High (Production) | Notes |
|----------|---------|:----------------:|:----------------:|:-----------------:|-------|
| Hosting | Vercel | Hobby $0 | Pro $20/mo | Pro $20/mo | Unlimited bandwidth |
| Database | Supabase | Free (500MB) | Pro $25/mo | Team $599/mo | Includes auth+storage |
| Email | Resend | Free (3K/mo) | Pro $20/mo | $20/mo | Best DX |
| ... | ... | ... | ... | ... | ... |

**Requirements:**
- List EVERY service from the architecture (hosting, database, auth, storage, email, monitoring, payment, LLM, third-party APIs)
- Break down by clear categories (minimum 5-8 categories based on architecture)
- Show specific tier names (not just prices): "Vercel Hobby $0" not just "$0"
- Include what's included in each tier in Notes column
- Show monthly totals for each scenario (Low/Medium/High)
- Show first-year total for each scenario

### 2. Development Costs (MANDATORY section)

**Always include development cost estimates based on complexity:**

**Time Estimation Formula:**
- Simple projects (complexity 1-3): 2-6 weeks
- Moderate projects (complexity 4-6): 6-12 weeks
- Complex projects (complexity 7-8): 12-20 weeks
- Very complex projects (complexity 9-10): 20-30+ weeks

**Rate Options (provide all three):**

| Option | Hourly Rate | Minimum (weeks) | Typical (weeks) | Maximum (weeks) | Total Range |
|--------|-------------|:---------------:|:---------------:|:---------------:|-------------|
| Solo Developer | $50-150/hr | [complexity × 2] | [complexity × 3] | [complexity × 4] | $X - $Y |
| Contractor | $75-200/hr | [complexity × 2] | [complexity × 3] | [complexity × 4] | $X - $Y |
| Agency | $150-300/hr | [complexity × 2] | [complexity × 3] | [complexity × 4] | $X - $Y |

**Calculation example for complexity 5 (moderate):**
- Solo: 10-20 weeks × 40 hrs × $50-150 = $20,000 - $120,000
- Contractor: 10-20 weeks × 40 hrs × $75-200 = $30,000 - $160,000
- Agency: 10-20 weeks × 40 hrs × $150-300 = $60,000 - $240,000

**Factors that increase development time (+20-50% each):**
- Complex real-time features (WebSockets, live collaboration)
- Multi-tenancy with complex permission models
- Heavy data migration or integration with legacy systems
- Custom design system (not using component library)
- Advanced AI/ML features requiring training or fine-tuning
- High security/compliance requirements (SOC 2, HIPAA, PCI-DSS)

### 3. Cost Optimization Tips (minimum 5-7 specific tips)

**Each tip MUST:**
- Reference a specific service from the breakdown
- Include quantified savings where possible
- Be actionable (not generic advice)
- Be prioritized by impact (highest savings first)

**Template for each tip:**
```
✅ [Action to take]
   - Saves: $X/month or Y%
   - Effort: [hours/days]
   - Trade-off: [what you lose, if anything]
   - Example: [concrete implementation detail]
```

**Example tips:**
```
✅ Start on free tiers and upgrade only when you hit limits
   - Saves: $45-70/month initially
   - Effort: None (just don't upgrade prematurely)
   - Trade-off: May need to upgrade quickly if growth spikes
   - Example: Supabase free tier supports 50K MAU, Vercel Hobby supports unlimited bandwidth

✅ Batch email notifications instead of real-time
   - Saves: ~60% on email costs ($12-18/mo)
   - Effort: 2-3 hours to implement digest system
   - Trade-off: Notifications delayed by 15-30 minutes
   - Example: Instead of 10K individual emails, send 2K daily digests (500 users × 4 emails/day → 1 digest)

✅ Use Cloudflare R2 instead of AWS S3 for public assets
   - Saves: $50-200/mo on egress fees at 1TB/month traffic
   - Effort: 4-6 hours migration
   - Trade-off: Slightly smaller ecosystem than S3
   - Example: R2 has zero egress fees; S3 charges $90/TB

✅ Implement Redis caching for database queries
   - Saves: $30-100/mo by reducing database tier needed
   - Effort: 1-2 days implementation
   - Trade-off: Added complexity, cache invalidation logic
   - Example: Cache user profile queries (10K/day → 100/day DB hits) allows staying on $25 tier

✅ Use serverless functions instead of always-on containers
   - Saves: $30-70/mo for low-traffic APIs (<1M req/mo)
   - Effort: Depends on existing architecture
   - Trade-off: Cold start latency (100-500ms)
   - Example: Cloud Run with min instances = 0 costs only $5/mo vs $50/mo for always-on

✅ Limit file upload sizes and use compression
   - Saves: $20-50/mo on storage costs
   - Effort: 2 hours to implement limits + compression
   - Trade-off: User experience if limits too strict
   - Example: 10MB limit + image compression reduces 50GB/mo uploads to 20GB/mo

✅ Use cheaper LLM models for simple tasks
   - Saves: 70-90% on LLM costs
   - Effort: 4-8 hours to implement model routing
   - Trade-off: Slightly lower quality for simple tasks
   - Example: Use Haiku ($0.80/MTok) for classification, Sonnet ($3/MTok) for generation
```

### 4. Cost Risk Flags (MANDATORY)

**Identify and explain services that can spike costs:**

**Pay-per-use traps** (services where costs grow non-linearly):
- LLM token costs: Can explode with long contexts or infinite loops
- Email services: Notification storms can send thousands of emails
- SMS: Verification code spam or loops
- Database bandwidth: Large table scans or missing indexes
- Serverless invocations: Retry loops or webhook spam

**Tier jump risks** (services with large price jumps between tiers):
- MongoDB Atlas: M0 Free → M10 $57 (+$57)
- Supabase: Free → Pro $25 (+$25) → Team $599 (+$574!)
- Auth0: Free 25K MAU → Essentials $35 for 500 MAU (danger if you grow past 500)
- PlanetScale: Free → Scaler $39 (+$39)

**Scale traps** (services that get expensive at scale):
- Datadog: $15/host/mo becomes $1,500/mo at 100 hosts
- Sentry: Volume pricing above free tier
- Real-time database subscriptions: Cost grows with concurrent connections
- Video/image processing: Pay per transcode/operation

**For each risk, provide:**
- Why it's risky (specific scenario that triggers high cost)
- Typical cost at risk ($X/month if it happens)
- Mitigation strategy (rate limiting, caps, monitoring, alternative)
- Warning threshold (set alert at $X usage)

**Example risk flag:**
```
⚠️ LLM Token Cost Risk — High
   Scenario: User creates chatbot with 50K context window and 1M conversations/month
   Cost: Could reach $5,000-15,000/month vs expected $100/month
   Mitigation:
   - Implement context window limits (8K max)
   - Add rate limiting per user (10 requests/minute)
   - Use prompt caching (reduces input token costs by 90%)
   - Set billing alerts at $500, $1000, $2000
   Warning: Monitor token usage daily for first 2 weeks
```

### 5. Scale Warnings (REQUIRED if project targets 1K+ users)

**Provide specific breakpoints where costs jump:**

**Format:**
```
🚨 Scale Warning: [Service Name]

Current Tier: [Name] ($X/mo)
Limit: [Specific metric]
Expected to hit limit: [Timeline based on growth projection]
Next tier: [Name] ($Y/mo, +$Z)

Migration plan:
1. [First step before hitting limit]
2. [Second step]
3. [Upgrade trigger point]

Cost projection:
- Month 1-3: $X/mo (free/current tier)
- Month 4-6: $Y/mo (upgraded tier)
- Month 7-12: $Z/mo (scale tier)
```

**Example:**
```
🚨 Scale Warning: Supabase Database

Current Tier: Free ($0/mo)
Limits: 500MB database, 1GB file storage, 50K MAU
Expected to hit limit: Month 2-3 at 500 active users with file uploads
Next tier: Pro ($25/mo, includes 8GB database, 100GB storage)

Migration plan:
1. Set up database size monitoring (alert at 400MB)
2. Implement file cleanup policy (delete after 90 days)
3. Optimize database indexes and queries
4. Upgrade to Pro when database reaches 450MB or 40K MAU

Cost projection:
- Month 1-2: $0/mo (free tier)
- Month 3-6: $25/mo (Pro tier)
- Month 7-12: $25/mo (Pro tier sufficient for 10K users)
- Year 2+: Consider Team tier ($599/mo) if exceeding 100K MAU
```

### 6. Monthly vs Yearly Summary (REQUIRED)

**Always provide both:**

| Scenario | Monthly Total | First Year Total | 3-Year Total |
|----------|:-------------:|:----------------:|:------------:|
| Low (Free tiers) | $X | $Y | $Z |
| Medium (Starter) | $X | $Y | $Z |
| High (Production) | $X | $Y | $Z |

**Include note about:**
- Annual payment discounts (typically 15-20% savings)
- Which services offer annual plans
- Reserved instance savings for compute (AWS/GCP/Azure: 30-70% savings)

### 7. Total Cost of Ownership (TCO) Summary

**Combine infrastructure + development + maintenance:**

```
Year 1 Total Cost of Ownership

Development (one-time):
- Solo developer: $X - $Y
- Contractor: $X - $Y
- Agency: $X - $Y

Infrastructure (recurring):
- Months 1-12 average: $X/month = $Y/year

Maintenance (ongoing):
- Bug fixes + minor updates: 10-20% of development cost/year = $X - $Y/year
- Major feature additions: Budget $X - $Y/quarter

Year 1 TCO Range:
- Minimum (solo dev + free tiers): $X
- Typical (contractor + starter tiers): $Y
- Maximum (agency + production tiers): $Z
```
