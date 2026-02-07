# Pricing Tables -- Quick Reference

> **Architect AI -- Cowork Plugin Reference**
> Pricing is approximate as of February 2026. Always verify against provider pages before finalizing estimates. Tiers are simplified for planning purposes; actual SKU names vary.

---

## 1. Cloud Compute

| Service | Free Tier | Starter (~$5-25/mo) | Production (~$50-200/mo) | Notes |
|---|---|---|---|---|
| AWS EC2 | 750 hrs/mo t2.micro (12 mo) | t3.small ~$15/mo | m6i.xlarge ~$140/mo | Reserved instances save 30-60% |
| AWS Lambda | 1M requests + 400K GB-s/mo | Pay-per-use ~$5-10/mo typical | Varies with traffic | Cold starts add 100-500ms |
| GCP Compute Engine | e2-micro always free | e2-small ~$13/mo | n2-standard-4 ~$120/mo | Sustained-use discounts auto-apply |
| GCP Cloud Run | 2M requests/mo | ~$5-15/mo typical | ~$50-150/mo | Per-request billing, no idle cost |
| Azure App Service | B1 free 60 min/day | B1 ~$13/mo | P1v3 ~$140/mo | Linux plans ~50% cheaper than Windows |
| DigitalOcean | -- | Basic 1 vCPU/1GB $6/mo | 4 vCPU/8GB $48/mo | Simple pricing, good for MVPs |
| Railway | $5 trial credits | Hobby $5/mo + usage | Pro $20/mo + usage | Easy deploys from Git |
| Fly.io | 3 shared VMs free | ~$5-15/mo | ~$50-100/mo | Edge deployment, good latency |
| Render | Static sites free | Starter $7/mo | Standard $25/mo+ | Free tier spins down after inactivity |
| Vercel | Hobby tier free | Pro $20/mo per member | Enterprise custom | Best for Next.js / frontend |
| Netlify | 100GB bandwidth/mo | Pro $19/mo per member | Enterprise custom | Serverless functions included |

---

## 2. Databases

| Service | Free Tier | Starter (~$15-30/mo) | Production (~$50-200/mo) | Notes |
|---|---|---|---|---|
| AWS RDS PostgreSQL | 750 hrs db.t3.micro (12 mo) | db.t3.small ~$25/mo | db.r6g.large ~$170/mo | Multi-AZ doubles cost |
| Supabase (Postgres) | 500MB, 2 projects | Pro $25/mo, 8GB | Team $599/mo | Includes Auth, Realtime, Storage |
| Neon (Postgres) | 0.5GB, 1 project | Launch $19/mo | Scale $69/mo | Serverless, branching, autoscale |
| PlanetScale (MySQL) | 1GB, 1B row reads/mo | Scaler $29/mo | Scaler Pro $99/mo | Branching workflow, no foreign keys |
| MongoDB Atlas | 512MB shared | M10 ~$60/mo | M30 ~$200/mo | Shared clusters cheaper but limited |
| Redis Cloud | 30MB | 250MB ~$7/mo | 1GB ~$30/mo | Also see Upstash for serverless |
| Upstash Redis | 10K commands/day | Pay-per-request ~$3-10/mo | Pro $50/mo | Serverless, good for edge |
| Upstash Kafka | 10K messages/day | Pay-per-message ~$5-15/mo | Pro custom | Serverless Kafka alternative |
| Pinecone (Vector) | 1 index, 100K vectors | Starter $70/mo | Standard ~$200/mo+ | Leading managed vector DB |
| Weaviate Cloud | Sandbox free (14 days) | Standard ~$25/mo | Business ~$135/mo+ | Open-source option available |
| Qdrant Cloud | 1GB free | ~$30/mo | ~$100/mo+ | Rust-based, strong performance |

---

## 3. LLM Token Pricing

| Model | Input (per 1M tokens) | Output (per 1M tokens) | Context Window | Notes |
|---|---|---|---|---|
| Claude Opus 4 | $15.00 | $75.00 | 200K | Most capable, complex tasks |
| Claude Sonnet 4 | $3.00 | $15.00 | 200K | Best balance of cost and quality |
| Claude Haiku 3.5 | $0.80 | $4.00 | 200K | Fast, cheapest Anthropic option |
| GPT-4o | $2.50 | $10.00 | 128K | OpenAI flagship multimodal |
| GPT-4o mini | $0.15 | $0.60 | 128K | Budget OpenAI option |
| o3 (reasoning) | $10.00 | $40.00 | 200K | Reasoning model, higher latency |
| o3-mini | $1.10 | $4.40 | 200K | Cheaper reasoning |
| Gemini 2.0 Pro | $1.25 | $5.00 | 1M+ | Google, large context |
| Gemini 2.0 Flash | $0.10 | $0.40 | 1M+ | Very cheap, fast |
| DeepSeek V3 | $0.27 | $1.10 | 64K | Open-weight, self-hostable |
| Llama 3.3 70B (Groq) | $0.59 | $0.79 | 128K | Via hosted inference |
| Mistral Large | $2.00 | $6.00 | 128K | European provider |
| Cohere Command R+ | $2.50 | $10.00 | 128K | Strong for RAG |

> **Estimation rule of thumb:** 1K tokens is roughly 750 words. A typical chat turn is 500-2000 tokens in + 200-1000 tokens out.

---

## 4. Auth Services

| Service | Free Tier | Starter | Production | Notes |
|---|---|---|---|---|
| Clerk | 10K MAU | Pro $25/mo + $0.02/MAU | Custom | Best DX, React-first |
| Auth0 | 25K MAU | Essential $35/mo | Professional $240/mo | Enterprise standard |
| Firebase Auth | 50K MAU (phone: 10K/mo) | Spark free, then pay-per-use | Blaze plan usage-based | Google ecosystem lock-in |
| Supabase Auth | Included in free tier | Included in Pro $25/mo | Included in Team plan | Bundled with Supabase DB |
| Kinde | 10.5K MAU | Pro $25/mo | Business $99/mo | Growing alternative |
| WorkOS | 1M MAU (free for AuthKit) | Pay-per-connection for SSO | Enterprise custom | Best for B2B / SSO |

---

## 5. Payment Processors

| Service | Transaction Fee | Monthly Fee | Payout Speed | Notes |
|---|---|---|---|---|
| Stripe | 2.9% + $0.30 | $0 | 2 days (instant avail.) | Developer standard, huge ecosystem |
| Stripe Billing | 0.5-0.8% on top of txn fee | $0 | 2 days | Subscription management built-in |
| Paddle | 5% + $0.50 | $0 | Net 15 | Merchant of record, handles tax |
| LemonSqueezy | 5% + $0.50 | $0 | Net 14 | Simpler Paddle alternative |
| PayPal | 2.99% + $0.49 | $0 | Instant to PayPal balance | Wide consumer reach |
| Square | 2.6% + $0.10 (in-person) | $0 | 1-2 days | In-person + online |

---

## 6. Email & SMS

| Service | Free Tier | Starter | Production | Notes |
|---|---|---|---|---|
| Resend | 3K emails/mo, 100/day | Pro $20/mo (50K emails) | Business $90/mo (100K) | Modern API, great DX |
| SendGrid | 100 emails/day | Essentials $20/mo (50K) | Pro $90/mo (100K) | Twilio-owned, reliable |
| AWS SES | 3K/mo (from EC2) | $0.10 per 1K emails | Same rate, volume discounts | Cheapest at scale |
| Postmark | 100 emails/mo | $15/mo (10K emails) | $85/mo (50K emails) | Best deliverability reputation |
| Mailgun | 100 emails/day trial | $35/mo (50K emails) | $90/mo (100K) | Strong API, good logs |
| Twilio SMS | Trial credit ~$15 | Pay-per-message ~$0.0079/msg | Volume discounts | Standard for SMS |
| AWS SNS (SMS) | 100 free publishes | ~$0.00645/msg (US) | Same rate | Cheaper, less features |

---

## 7. Monitoring & Error Tracking

| Service | Free Tier | Starter | Production | Notes |
|---|---|---|---|---|
| Sentry | 5K errors/mo | Team $26/mo | Business $80/mo | Industry standard error tracking |
| Datadog | 5 hosts, 1-day retention | Pro $15/host/mo | Enterprise $23/host/mo | Full observability, gets expensive |
| New Relic | 100GB ingest/mo, 1 user | Standard $0.30/GB+ | Pro $0.50/GB+ | Generous free tier |
| Grafana Cloud | 10K metrics, 50GB logs | Pro $29/mo | Advanced $299/mo | Open-source compatible |
| BetterStack | 10 monitors | Starter $24/mo | Business $85/mo | Uptime + logs combined |
| LogRocket | 1K sessions/mo | Team $99/mo | Professional $250/mo | Frontend session replay |
| PostHog | 1M events/mo, 5K replays | Pay-per-use | Pay-per-use | Product analytics + feature flags |

---

## 8. Storage & CDN

| Service | Free Tier | Starter | Production | Notes |
|---|---|---|---|---|
| AWS S3 | 5GB (12 mo) | ~$0.023/GB/mo | Same + reduced tiers | Standard for object storage |
| Cloudflare R2 | 10GB, 10M reads/mo | $0.015/GB/mo, no egress | Same rate | No egress fees, S3-compatible |
| Supabase Storage | 1GB included | 100GB in Pro plan | 200GB in Team plan | Tied to Supabase project |
| Uploadthing | 2GB | Pro $10/mo (100GB) | Custom | File uploads for Next.js |
| Cloudflare CDN | Unlimited (on their DNS) | Pro $20/mo (domain) | Business $200/mo | Essentially free for most uses |
| AWS CloudFront | 1TB transfer/mo (12 mo) | ~$0.085/GB first 10TB | Tiered pricing | Pairs with S3 |
| Bunny CDN | -- | Pay-per-use ~$0.01/GB | Volume discounts | Cheapest CDN option |
| Vercel Blob | 250MB | Pro includes 1GB | Additional at $0.15/GB | Simple, integrated with Vercel |
| imgix | -- | Starter $25/mo | Growth $100/mo | Image optimization CDN |

---

## Quick Cost Estimation Anchors

| App Stage | Typical Monthly Cost | Stack Profile |
|---|---|---|
| **Prototype / MVP** | $0-30 | Free tiers + serverless + managed DB free tier |
| **Early users (< 1K)** | $30-150 | Small VPS or PaaS + managed DB starter + basic monitoring |
| **Growth (1K-10K users)** | $150-800 | Dedicated compute + production DB + CDN + error tracking |
| **Scale (10K-100K users)** | $800-5,000 | Multi-service infra + caching layer + observability suite |
| **Large scale (100K+)** | $5,000+ | Reserved instances + multi-region + dedicated support tiers |

---

*Last reviewed: February 2026. Use as a starting point for estimates, not as a contractual reference.*
