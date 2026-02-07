# Service Profiles — Extended Reference

Extended profiles for the Architect AI plugin's `known-services` skill. Each entry adds setup guidance, environment variables, common pitfalls, and alternatives beyond the condensed profiles in `skills/known-services/SKILL.md`.

---

## 1. Authentication

### Auth0
**What:** Enterprise-grade identity platform with universal login, MFA, and social connections.
**When to use:** You need advanced features like RBAC, breached-password detection, or enterprise SSO (SAML/OIDC) out of the box.
**Setup time:** ~30 minutes.
**Env variables:** `AUTH0_DOMAIN`, `AUTH0_CLIENT_ID`, `AUTH0_CLIENT_SECRET`, `AUTH0_AUDIENCE` (for API authorization).
**Gotchas:** Tenant naming is permanent. The free tier does not include custom domains. Rate limits on Management API calls are strict on lower plans. Action/Rule execution order can cause subtle bugs.
**Alternatives:** Clerk, Kinde, Supabase Auth.

### Clerk
**What:** Drop-in auth UI components with session management, designed for Next.js and React.
**When to use:** You want beautiful, pre-built sign-in/sign-up components with minimal custom code, especially in a Next.js project.
**Setup time:** ~15 minutes.
**Env variables:** `NEXT_PUBLIC_CLERK_PUBLISHABLE_KEY`, `CLERK_SECRET_KEY`, `NEXT_PUBLIC_CLERK_SIGN_IN_URL`, `NEXT_PUBLIC_CLERK_SIGN_UP_URL`.
**Gotchas:** Tightly coupled to its own user model; migrating users away later requires export. Middleware configuration must be precise or routes break silently. Free tier MAU limit (10K) can be reached quickly in viral launches.
**Alternatives:** Auth0, Kinde, NextAuth/Auth.js.

### Supabase Auth
**What:** Auth module bundled with Supabase's PostgreSQL platform, supporting email, OAuth, and magic links.
**When to use:** You are already using Supabase for your database and want auth without adding another vendor.
**Setup time:** ~10 minutes (auth is enabled by default on project creation).
**Env variables:** `NEXT_PUBLIC_SUPABASE_URL`, `NEXT_PUBLIC_SUPABASE_ANON_KEY`, `SUPABASE_SERVICE_ROLE_KEY`.
**Gotchas:** Row-level security (RLS) policies must be configured manually or your data is exposed. Email confirmation is on by default and can confuse users in dev. The `service_role` key bypasses RLS, so never expose it client-side.
**Alternatives:** Firebase Auth, Auth0, Clerk.

### Firebase Auth
**What:** Google-backed auth with broad provider support (Google, Apple, phone, email, anonymous).
**When to use:** You are building a mobile-first product or already use other Firebase services (Firestore, Cloud Functions).
**Setup time:** ~20 minutes.
**Env variables:** `FIREBASE_API_KEY`, `FIREBASE_AUTH_DOMAIN`, `FIREBASE_PROJECT_ID`. For admin SDK: `GOOGLE_APPLICATION_CREDENTIALS` (path to service account JSON).
**Gotchas:** Client-side SDK is large (~80 KB). No built-in RBAC; you must use custom claims. Exporting users requires the Admin SDK. Emulator suite is helpful but has behavioral differences from production.
**Alternatives:** Supabase Auth, Auth0, Clerk.

### Kinde
**What:** Auth platform with built-in feature flags and user management, focused on developer experience.
**When to use:** You want auth plus feature flagging from a single vendor and prefer a generous free tier (10.5K MAU).
**Setup time:** ~15 minutes.
**Env variables:** `KINDE_DOMAIN`, `KINDE_CLIENT_ID`, `KINDE_CLIENT_SECRET`, `KINDE_REDIRECT_URL`, `KINDE_LOGOUT_REDIRECT_URL`.
**Gotchas:** Newer service with a smaller community; fewer Stack Overflow answers. SDK coverage for non-JS frameworks is still catching up. Webhook support is more limited than Auth0.
**Alternatives:** Clerk, Auth0, Supabase Auth.

### NextAuth / Auth.js
**What:** Open-source, framework-agnostic auth library (formerly NextAuth.js) with adapters for many databases.
**When to use:** You want full control over auth logic and data, no vendor lock-in, and you are comfortable self-hosting session storage.
**Setup time:** ~20-40 minutes (depends on provider and database adapter).
**Env variables:** `NEXTAUTH_URL`, `NEXTAUTH_SECRET`, plus per-provider vars like `GITHUB_CLIENT_ID`, `GITHUB_CLIENT_SECRET`, `GOOGLE_CLIENT_ID`, `GOOGLE_CLIENT_SECRET`.
**Gotchas:** v5 (Auth.js) has breaking changes from v4 (NextAuth). Database adapter setup is a common source of errors. Session strategy (JWT vs. database) choice affects architecture. No managed dashboard; you build your own user management.
**Alternatives:** Clerk, Kinde, Supabase Auth.

---

## 2. Payments

### Stripe
**What:** Full-featured payments infrastructure with subscriptions, invoicing, and a developer-first API.
**When to use:** You need subscriptions, one-time payments, marketplace payouts, or usage-based billing with maximum flexibility.
**Setup time:** ~30-60 minutes (basic checkout); longer for subscriptions with webhooks.
**Env variables:** `STRIPE_PUBLISHABLE_KEY`, `STRIPE_SECRET_KEY`, `STRIPE_WEBHOOK_SECRET`, `STRIPE_PRICE_ID`.
**Gotchas:** You handle tax compliance yourself (unless using Stripe Tax). Webhook signature verification is essential but easy to forget. Test mode and live mode have separate API keys. Subscription lifecycle events are complex; map out state transitions before building.
**Alternatives:** Paddle, LemonSqueezy.

### Paddle
**What:** Merchant of record (MoR) platform that handles global tax, invoicing, and compliance on your behalf.
**When to use:** You sell digital products globally and do not want to manage sales tax, VAT, or invoicing yourself.
**Setup time:** ~1-3 days (includes account approval).
**Env variables:** `PADDLE_VENDOR_ID`, `PADDLE_AUTH_CODE`, `PADDLE_PUBLIC_KEY`, `PADDLE_WEBHOOK_SECRET`.
**Gotchas:** Account approval process can take days. Higher per-transaction fee than Stripe (5% + $0.50). Fewer customization options for checkout UI. Limited support for physical goods or complex marketplace models.
**Alternatives:** LemonSqueezy, Stripe (with Stripe Tax).

### LemonSqueezy
**What:** Merchant of record platform with a simple API, targeting indie developers and SaaS products.
**When to use:** You are a solo developer or small team selling digital products/subscriptions and want the simplest possible setup with tax handled.
**Setup time:** ~20 minutes.
**Env variables:** `LEMONSQUEEZY_API_KEY`, `LEMONSQUEEZY_STORE_ID`, `LEMONSQUEEZY_WEBHOOK_SECRET`.
**Gotchas:** Smaller ecosystem and fewer integrations than Stripe. Payout schedule is slower (you receive funds after a delay). API is less mature for edge cases. Support response times can be longer during peak periods.
**Alternatives:** Paddle, Stripe.

---

## 3. Databases

### Supabase (PostgreSQL)
**What:** Managed PostgreSQL with a real-time engine, auto-generated REST/GraphQL APIs, and a dashboard.
**When to use:** You want a relational database with built-in auth, real-time subscriptions, and storage without stitching multiple services together.
**Setup time:** ~5 minutes.
**Env variables:** `SUPABASE_URL`, `SUPABASE_ANON_KEY`, `SUPABASE_SERVICE_ROLE_KEY`, `DATABASE_URL` (direct Postgres connection).
**Gotchas:** Free tier pauses after 1 week of inactivity. RLS must be configured for security. The auto-generated API exposes all tables unless you restrict access. Large migrations can time out on free tier.
**Alternatives:** Neon, PlanetScale, MongoDB Atlas.

### MongoDB Atlas
**What:** Managed MongoDB with global clusters, full-text search (Atlas Search), and a flexible document model.
**When to use:** Your data is naturally document-shaped, schemas evolve frequently, or you need built-in full-text search.
**Setup time:** ~10 minutes.
**Env variables:** `MONGODB_URI` (connection string with credentials embedded).
**Gotchas:** M0 free tier has no backups and limited monitoring. IP allowlisting is required; forgetting it causes connection failures. Schema-less flexibility can lead to data inconsistency if not managed with validation rules. Aggregation pipelines have a learning curve.
**Alternatives:** Supabase, Neon, Turso.

### Neon (PostgreSQL)
**What:** Serverless PostgreSQL with branching, autoscaling to zero, and a generous free tier.
**When to use:** You want PostgreSQL with minimal ops overhead and the ability to branch databases for preview deployments or testing.
**Setup time:** ~5 minutes.
**Env variables:** `DATABASE_URL` (Neon connection string). Use `?sslmode=require` for production.
**Gotchas:** Cold starts can add latency on first query after idle. Free tier limited to 1 project and 100 compute hours/month. Branching is powerful but can be confusing if you are unfamiliar with the concept. Connection pooling (via their proxy) is recommended for serverless.
**Alternatives:** Supabase, PlanetScale, Turso.

### PlanetScale (MySQL)
**What:** Managed MySQL platform with non-blocking schema changes and database branching.
**When to use:** You need MySQL specifically, want zero-downtime schema migrations, or have an existing MySQL-based codebase.
**Setup time:** ~10 minutes.
**Env variables:** `DATABASE_HOST`, `DATABASE_USERNAME`, `DATABASE_PASSWORD`. Or a single `DATABASE_URL` with the PlanetScale driver.
**Gotchas:** Foreign key constraints are not supported (by design, for scalability). The free tier was removed in 2024; paid plans start at $39/month. Branch-based workflow requires discipline to avoid drift. Use `@planetscale/database` driver for serverless edge compatibility.
**Alternatives:** Neon, Supabase, Turso.

### Upstash Redis
**What:** Serverless Redis with per-request pricing and a REST API designed for edge and serverless functions.
**When to use:** You need caching, rate limiting, session storage, or queues in a serverless environment where persistent connections are impractical.
**Setup time:** ~5 minutes.
**Env variables:** `UPSTASH_REDIS_REST_URL`, `UPSTASH_REDIS_REST_TOKEN`.
**Gotchas:** REST-based access adds slight latency compared to native Redis TCP connections. Free tier is limited to 10K commands/day, which can be hit quickly under load. Data eviction policies differ from self-hosted Redis defaults. Not a replacement for a primary database.
**Alternatives:** Redis Cloud, Momento, DynamoDB (for key-value patterns).

### Pinecone
**What:** Managed vector database for similarity search, purpose-built for AI/ML embedding use cases.
**When to use:** You are building RAG (retrieval-augmented generation), semantic search, or recommendation systems that query high-dimensional vectors.
**Setup time:** ~10 minutes.
**Env variables:** `PINECONE_API_KEY`, `PINECONE_ENVIRONMENT`, `PINECONE_INDEX_NAME`.
**Gotchas:** Costs scale with vector count and dimensions; high-dimensional embeddings get expensive quickly. Index creation takes a few minutes. Free tier allows only 1 index. Metadata filtering options are limited compared to traditional databases. Consider your embedding model's dimension size before creating the index.
**Alternatives:** Weaviate, Qdrant, Supabase pgvector, ChromaDB.

### Turso (SQLite)
**What:** Edge-hosted, distributed SQLite built on libSQL with replication across regions.
**When to use:** You want SQLite simplicity with multi-region replication and low-latency reads at the edge.
**Setup time:** ~10 minutes.
**Env variables:** `TURSO_DATABASE_URL`, `TURSO_AUTH_TOKEN`.
**Gotchas:** Write operations go to the primary region; replicas are read-only. The ecosystem is younger than PostgreSQL/MySQL, so ORM support is still maturing. SQLite syntax differences can catch PostgreSQL developers off guard. Embedded replicas for local-first patterns require careful sync logic.
**Alternatives:** Neon, Supabase, PlanetScale.

---

## 4. Email

### Resend
**What:** Modern email API with React Email integration for building emails with components.
**When to use:** You are in a React/Next.js stack and want to design emails using JSX components rather than raw HTML templates.
**Setup time:** ~15 minutes (including domain verification).
**Env variables:** `RESEND_API_KEY`.
**Gotchas:** Domain verification (DNS records) is required for production sends; this step trips up many developers. Free tier is limited to 1 custom domain. Relatively new; fewer templates and community resources than SendGrid. Delivery to some enterprise inboxes may need SPF/DKIM tuning.
**Alternatives:** SendGrid, Postmark, AWS SES.

### SendGrid
**What:** Established email delivery platform with SMTP relay, marketing campaigns, and analytics dashboards.
**When to use:** You need both transactional and marketing email from one platform, or you need proven deliverability at scale.
**Setup time:** ~20 minutes.
**Env variables:** `SENDGRID_API_KEY`, `SENDGRID_FROM_EMAIL`.
**Gotchas:** Free tier is only 100 emails/day, which is easy to exceed during testing. Account provisioning sometimes triggers manual review, blocking sends for 24-48 hours. The dashboard is feature-heavy and can feel overwhelming. Dynamic template syntax (Handlebars) has quirks.
**Alternatives:** Resend, Postmark, AWS SES.

### Postmark
**What:** Transactional email service focused on deliverability with message streams and template management.
**When to use:** Transactional email deliverability is your top priority (password resets, receipts, notifications) and you need reliable inbox placement.
**Setup time:** ~15 minutes.
**Env variables:** `POSTMARK_SERVER_TOKEN`, `POSTMARK_FROM_EMAIL`.
**Gotchas:** Postmark explicitly prohibits bulk marketing email; your account can be suspended if you send campaigns. Free tier is only 100 emails/month. Separate message streams (transactional vs. broadcast) must be configured correctly. SMTP header approach differs from API approach.
**Alternatives:** Resend, SendGrid, AWS SES.

### AWS SES
**What:** AWS-native email sending service with the lowest per-message cost at scale.
**When to use:** You are already on AWS, need to send high volume at minimal cost, and are comfortable with AWS IAM and configuration.
**Setup time:** ~30-60 minutes (longer if requesting production access out of sandbox).
**Env variables:** `AWS_ACCESS_KEY_ID`, `AWS_SECRET_ACCESS_KEY`, `AWS_REGION`, `SES_FROM_EMAIL`.
**Gotchas:** Starts in sandbox mode (can only send to verified addresses). Production access request can take 24+ hours. No built-in template editor; you manage HTML yourself. Bounce and complaint handling must be configured via SNS topics or you risk account suspension.
**Alternatives:** Resend, SendGrid, Postmark.

---

## 5. Hosting & Deployment

### Vercel
**What:** Frontend cloud platform optimized for Next.js with edge functions, preview deploys, and serverless APIs.
**When to use:** You are deploying a Next.js, SvelteKit, or Nuxt app and want zero-config CI/CD with preview URLs per pull request.
**Setup time:** ~5 minutes.
**Env variables:** Set via dashboard or `vercel env pull`. Common: `VERCEL_URL`, `VERCEL_ENV`. Project-specific env vars configured in project settings.
**Gotchas:** Serverless function timeout is 10s on Hobby (60s on Pro). Hobby plan is non-commercial. Bandwidth overages are expensive. Monorepo support works but requires careful `vercel.json` configuration. Cold starts on serverless functions add latency.
**Alternatives:** Netlify, Cloudflare Pages, Railway.

### Netlify
**What:** Web platform with build plugins, serverless functions, and form handling, strong for static sites and Jamstack.
**When to use:** You are deploying a static site, Astro, or Gatsby project and want built-in form handling and identity without external services.
**Setup time:** ~5 minutes.
**Env variables:** Set via dashboard under Site settings > Environment. Common: `URL`, `DEPLOY_URL`.
**Gotchas:** Serverless function timeout is 10s (26s on background functions, paid). Build minutes are limited to 300/month on free tier. Next.js support is via an adapter that lags behind Vercel's native support. Large site builds can be slow; incremental builds help but require configuration.
**Alternatives:** Vercel, Cloudflare Pages, Render.

### Railway
**What:** Full-stack cloud platform that deploys any Dockerfile or language with managed databases as add-ons.
**When to use:** You need to deploy a backend service (Node, Python, Go, etc.) with a database, Redis, or other infrastructure alongside it.
**Setup time:** ~10 minutes.
**Env variables:** Set via dashboard or CLI. Railway auto-injects variables for provisioned services (e.g., `DATABASE_URL` for Postgres add-on).
**Gotchas:** Free trial credit ($5) runs out quickly with always-on services. No built-in CDN for static assets. Pricing is usage-based, which can be unpredictable. Sleep behavior on the free tier can cause cold-start latency.
**Alternatives:** Render, Fly.io, Heroku.

### Render
**What:** Cloud platform with managed PostgreSQL, Redis, cron jobs, and auto-deploy from Git.
**When to use:** You want a Heroku-like experience with a free tier for side projects and straightforward scaling for production.
**Setup time:** ~10 minutes.
**Env variables:** Set via dashboard under Environment tab. Render provides `RENDER_EXTERNAL_URL` and `RENDER_SERVICE_ID` automatically.
**Gotchas:** Free web services spin down after 15 minutes of inactivity (50+ second cold starts). Free PostgreSQL databases are deleted after 90 days. Build times can be slow on shared infrastructure. Auto-scaling is only available on paid plans.
**Alternatives:** Railway, Fly.io, Heroku.

### Fly.io
**What:** App platform that deploys Docker containers to edge servers worldwide using Firecracker micro-VMs.
**When to use:** You need multi-region deployment for low-latency global access, or you are deploying a non-trivial backend (Elixir, Go, Rust) that benefits from running close to users.
**Setup time:** ~15 minutes.
**Env variables:** Set via `fly secrets set KEY=VALUE`. Common: `FLY_APP_NAME`, `PRIMARY_REGION`, `DATABASE_URL`.
**Gotchas:** CLI-driven workflow has a learning curve. Free tier VMs are shared and can be noisy-neighbor affected. Persistent storage (volumes) is pinned to a single region. Postgres on Fly is self-managed (not a fully managed service). Networking configuration for multi-region can be complex.
**Alternatives:** Railway, Render, AWS ECS.

### AWS (General)
**What:** The most comprehensive cloud platform with 200+ services covering compute, storage, AI, networking, and more.
**When to use:** You need fine-grained infrastructure control, enterprise compliance, or services not available elsewhere (e.g., Lambda@Edge, SQS, DynamoDB).
**Setup time:** Varies widely; ~30 minutes for basic setup, days for production-grade infrastructure.
**Env variables:** `AWS_ACCESS_KEY_ID`, `AWS_SECRET_ACCESS_KEY`, `AWS_REGION`, `AWS_SESSION_TOKEN` (for temporary credentials).
**Gotchas:** Billing surprises are the biggest risk; always set billing alerts. IAM permissions are powerful but complex. The free tier has time limits (12 months for many services). Service naming is often unintuitive. Use infrastructure-as-code (CDK, Terraform) from day one.
**Alternatives:** GCP, Azure, Vercel + Railway (for simpler stacks).

---

## 6. Storage

### AWS S3
**What:** Object storage with virtually unlimited capacity, fine-grained access control, and CDN integration via CloudFront.
**When to use:** You need reliable, scalable file storage for user uploads, backups, static assets, or data lake workloads.
**Setup time:** ~15 minutes.
**Env variables:** `AWS_ACCESS_KEY_ID`, `AWS_SECRET_ACCESS_KEY`, `AWS_REGION`, `S3_BUCKET_NAME`.
**Gotchas:** Buckets are globally unique; good names are often taken. CORS must be configured for browser-based uploads. Public access is blocked by default (good), but misconfiguring bucket policies can expose data. Costs include storage, requests, and egress; egress fees add up fast.
**Alternatives:** Cloudflare R2, Google Cloud Storage, Uploadthing.

### Cloudflare R2
**What:** S3-compatible object storage with zero egress fees, integrated with the Cloudflare network.
**When to use:** You want S3-compatible storage but egress costs are a concern, or you are already using Cloudflare Workers.
**Setup time:** ~10 minutes.
**Env variables:** `R2_ACCOUNT_ID`, `R2_ACCESS_KEY_ID`, `R2_SECRET_ACCESS_KEY`, `R2_BUCKET_NAME`, `R2_ENDPOINT`.
**Gotchas:** No built-in CDN caching for R2 (use a Cloudflare Worker or custom domain in front). API compatibility is S3-like but not 100%; some S3 features (e.g., certain lifecycle policies) are missing. Dashboard UI is less mature than S3 console. Multipart upload has minimum part sizes.
**Alternatives:** AWS S3, Google Cloud Storage, Backblaze B2.

### Uploadthing
**What:** File upload service for Next.js/React with type-safe routes, built-in components, and managed storage.
**When to use:** You are in a TypeScript/Next.js stack and want file uploads with minimal boilerplate, including pre-built UI components.
**Setup time:** ~10 minutes.
**Env variables:** `UPLOADTHING_SECRET`, `UPLOADTHING_APP_ID`.
**Gotchas:** Tightly coupled to React/Next.js; not ideal for non-JS backends. Free tier storage (2 GB) fills up quickly with media files. File size limits apply per plan. Less flexibility than raw S3 for advanced use cases (transformations, lifecycle rules).
**Alternatives:** AWS S3, Cloudflare R2, Firebase Storage.

---

## 7. Monitoring & Analytics

### Sentry
**What:** Error tracking and performance monitoring platform with stack traces, breadcrumbs, and release tracking.
**When to use:** You need to catch, triage, and debug runtime errors across frontend and backend with full context (stack trace, user info, request data).
**Setup time:** ~10 minutes.
**Env variables:** `SENTRY_DSN`, `SENTRY_AUTH_TOKEN` (for source maps), `SENTRY_ORG`, `SENTRY_PROJECT`.
**Gotchas:** Source map upload is essential for readable stack traces in production but is a common setup stumbling block. Free tier (5K errors/month) can be consumed by a single bug in a loop. Alert fatigue is real; tune alert rules early. SDK bundle size impact (~20-30 KB) should be considered for performance-sensitive apps.
**Alternatives:** PostHog (basic error tracking), Datadog, LogRocket.

### PostHog
**What:** Open-source product analytics with event tracking, session recordings, feature flags, and A/B testing.
**When to use:** You want product analytics, session replay, and feature flags from a single open-source platform, or you need to self-host analytics for compliance.
**Setup time:** ~10 minutes.
**Env variables:** `NEXT_PUBLIC_POSTHOG_KEY`, `NEXT_PUBLIC_POSTHOG_HOST`.
**Gotchas:** Auto-capture is convenient but generates high event volume that can eat through the free tier. Session recordings increase storage usage significantly. Self-hosting requires a beefy server (ClickHouse is resource-hungry). The feature flag SDK must be loaded before feature checks or you get flicker.
**Alternatives:** Mixpanel, Amplitude, Google Analytics, Sentry.

### Datadog
**What:** Enterprise observability platform covering logs, metrics, APM traces, and infrastructure monitoring.
**When to use:** You need deep infrastructure visibility across multiple services, hosts, and cloud providers with correlated logs, metrics, and traces.
**Setup time:** ~30 minutes (agent installation plus integration configuration).
**Env variables:** `DD_API_KEY`, `DD_APP_KEY`, `DD_SITE` (e.g., `datadoghq.com`), `DD_ENV`, `DD_SERVICE`.
**Gotchas:** Pricing is complex and per-host; costs escalate quickly as you scale. The agent must be installed on every host. Custom metrics are charged separately. Free tier is limited to 5 hosts with 1-day retention, which is barely enough for evaluation. Configuration-as-code is recommended to avoid dashboard/monitor drift.
**Alternatives:** Sentry, New Relic, Grafana Cloud, PostHog.

---

## 8. Search

### Algolia
**What:** Hosted search engine with typo tolerance, faceting, and pre-built UI components (InstantSearch).
**When to use:** You need fast, typo-tolerant search with faceted navigation and you want pre-built UI widgets to get to production quickly.
**Setup time:** ~20 minutes.
**Env variables:** `ALGOLIA_APP_ID`, `ALGOLIA_SEARCH_API_KEY` (public, read-only), `ALGOLIA_ADMIN_API_KEY` (server-side only).
**Gotchas:** Record size limit is 10 KB; large documents must be split. Costs are based on search requests and records; can get expensive at scale. Two API keys exist (search vs. admin); leaking the admin key is a security risk. Index updates are near-real-time but not instant. Re-indexing large datasets requires careful batching.
**Alternatives:** Typesense, Meilisearch, Elasticsearch.

### Typesense
**What:** Open-source search engine with a focus on simplicity, typo tolerance, and low latency.
**When to use:** You want an Algolia-like experience but prefer open-source with self-hosting options, or you need predictable pricing on Typesense Cloud.
**Setup time:** ~15 minutes (cloud) or ~30 minutes (self-hosted).
**Env variables:** `TYPESENSE_API_KEY`, `TYPESENSE_HOST`, `TYPESENSE_PORT`, `TYPESENSE_PROTOCOL`.
**Gotchas:** Schema must be defined before indexing (not schemaless). Cloud free tier has limited resources. Geosearch and vector search are available but less mature than Algolia. Community is smaller; fewer tutorials and Stack Overflow answers. Cluster scaling requires manual intervention on self-hosted.
**Alternatives:** Algolia, Meilisearch, Elasticsearch.

### Meilisearch
**What:** Open-source, Rust-based search engine with instant results, typo tolerance, and a simple REST API.
**When to use:** You want fast, easy-to-configure search for small-to-medium datasets and prefer open-source with optional managed cloud hosting.
**Setup time:** ~15 minutes.
**Env variables:** `MEILISEARCH_HOST`, `MEILISEARCH_API_KEY` (master key for admin, search key for client).
**Gotchas:** Designed for datasets up to a few million documents; not ideal for massive-scale search. Runs entirely in memory for indexing, so RAM requirements can be high. Cloud offering is newer with limited region availability. Relevancy tuning options are less granular than Algolia. Filterable attributes must be declared before use.
**Alternatives:** Algolia, Typesense, Elasticsearch.

---

## 9. Maps & Location

### Google Maps
**What:** Industry-standard mapping platform with geocoding, directions, Street View, and Places API.
**When to use:** You need comprehensive mapping with the broadest global coverage, or your users expect the Google Maps look and feel.
**Setup time:** ~15 minutes.
**Env variables:** `GOOGLE_MAPS_API_KEY`. Optionally `GOOGLE_MAPS_MAP_ID` for cloud-based map styling.
**Gotchas:** API key must be restricted by HTTP referrer (frontend) or IP (backend) to prevent abuse. The $200/month free credit covers ~28K map loads but is easy to exceed. Each API (Maps, Places, Directions, Geocoding) is billed separately. The JavaScript SDK is large; lazy-load it. Terms of service prohibit caching map tiles or geocoding results beyond short-term.
**Alternatives:** Mapbox, Leaflet (with OpenStreetMap tiles).

### Mapbox
**What:** Developer-focused mapping platform with customizable styles, 3D terrain, and navigation SDKs.
**When to use:** You need heavily customized map styling, 3D visualizations, or turn-by-turn navigation with more design flexibility than Google Maps.
**Setup time:** ~10 minutes.
**Env variables:** `MAPBOX_ACCESS_TOKEN`. Optionally `MAPBOX_STYLE_URL` for custom styles.
**Gotchas:** Free tier (50K map loads/month) is generous but pricing scales steeply. Attribution is required on all maps (Mapbox logo and OpenStreetMap credit). Geocoding accuracy in some regions is lower than Google. React wrapper (`react-map-gl`) has version compatibility issues between v6 and v7. Offline maps require a mobile SDK with additional setup.
**Alternatives:** Google Maps, Leaflet (with OpenStreetMap tiles), HERE Maps.

---

## 10. Notifications

### OneSignal
**What:** Multi-channel notification platform supporting push (web, mobile), email, SMS, and in-app messaging.
**When to use:** You need cross-platform push notifications with segmentation, A/B testing, and analytics without building your own notification infrastructure.
**Setup time:** ~15 minutes (web push); ~30 minutes (mobile with native SDKs).
**Env variables:** `ONESIGNAL_APP_ID`, `ONESIGNAL_REST_API_KEY`.
**Gotchas:** Web push requires HTTPS. Mobile push setup requires platform-specific certificates (APNs for iOS, FCM key for Android). Free tier limits web push to 10K subscribers. The SDK adds weight to your bundle. Notification delivery is best-effort; there is no guaranteed delivery SLA on free plans. Segmentation logic can become complex.
**Alternatives:** Novu, Firebase Cloud Messaging, Pusher.

### Novu
**What:** Open-source notification infrastructure with a unified API for push, email, SMS, in-app, and chat channels.
**When to use:** You want to manage notification workflows across multiple channels (email, push, in-app) from a single codebase with a visual template editor.
**Setup time:** ~20 minutes.
**Env variables:** `NOVU_API_KEY`, `NOVU_APP_ID`, `NOVU_SUBSCRIBER_ID` (per user).
**Gotchas:** Self-hosting is possible but complex (multiple microservices). Cloud free tier is limited to 30K events/month. The in-app notification center component is React-only. Provider integrations (SendGrid, Twilio, etc.) must be configured per channel. The workflow editor has a learning curve for complex conditional flows.
**Alternatives:** OneSignal, Knock, Firebase Cloud Messaging.

### Firebase Cloud Messaging (FCM)
**What:** Google's free, cross-platform messaging service for push notifications on Android, iOS, and web.
**When to use:** You are already in the Firebase ecosystem, need unlimited free push notifications, or are building primarily for Android.
**Setup time:** ~20 minutes.
**Env variables:** `FIREBASE_API_KEY`, `FIREBASE_PROJECT_ID`, `FIREBASE_MESSAGING_SENDER_ID`, `FIREBASE_APP_ID`. Server-side: `GOOGLE_APPLICATION_CREDENTIALS` (service account).
**Gotchas:** iOS requires APNs certificate configuration in the Firebase console. Web push requires a service worker (`firebase-messaging-sw.js`). No built-in analytics for notification engagement (use Firebase Analytics separately). Message payload is limited to 4 KB. Topic messaging is powerful but unsubscribing users requires client-side logic. No guaranteed delivery order.
**Alternatives:** OneSignal, Novu, Amazon SNS.

---

## Quick Comparison Matrix

| Category         | Fastest Setup   | Most Flexible     | Best Free Tier       |
|------------------|-----------------|-------------------|----------------------|
| Authentication   | Supabase Auth   | Auth0             | Firebase Auth (50K)  |
| Payments         | LemonSqueezy    | Stripe            | All pay-per-use      |
| Database         | Supabase        | AWS (RDS/DynamoDB) | Turso (9 GB)        |
| Email            | Resend          | AWS SES           | Resend (3K/mo)       |
| Hosting          | Vercel          | AWS               | Fly.io (3 VMs)       |
| Storage          | Uploadthing     | AWS S3            | Cloudflare R2        |
| Monitoring       | Sentry          | Datadog           | PostHog (1M events)  |
| Search           | Meilisearch     | Algolia           | Meilisearch (Cloud)  |
| Maps             | Mapbox          | Google Maps       | Google Maps ($200)   |
| Notifications    | FCM             | Novu              | FCM (unlimited)      |
