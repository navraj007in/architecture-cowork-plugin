---
name: known-services
description: Setup steps, credentials, free tiers, and documentation links for 70+ commonly used services. Use when listing required accounts or recommending third-party services.
---

# Known Services Library

Condensed profiles for commonly used services in modern software architecture. Each profile includes what you need to get started: signup, setup steps, credentials, free tier, and documentation.

For the full extended library, see `references/service-profiles.md`.

---

## Authentication

### Auth0
- **Signup:** https://auth0.com/signup
- **Setup:** Create tenant → Create application → Configure callback URLs → Install SDK
- **Credentials:** Domain, Client ID, Client Secret
- **Free tier:** 25,000 MAU, unlimited logins
- **Docs:** https://auth0.com/docs

### Clerk
- **Signup:** https://clerk.com/sign-up
- **Setup:** Create application → Install `@clerk/nextjs` → Add middleware → Add `<ClerkProvider>`
- **Credentials:** Publishable Key, Secret Key
- **Free tier:** 10,000 MAU
- **Docs:** https://clerk.com/docs

### Firebase Auth
- **Signup:** https://console.firebase.google.com
- **Setup:** Create project → Enable auth providers → Install Firebase SDK → Initialize app
- **Credentials:** Firebase config object (apiKey, authDomain, projectId)
- **Free tier:** 50,000 MAU for most providers
- **Docs:** https://firebase.google.com/docs/auth

### Supabase Auth
- **Signup:** https://supabase.com/dashboard
- **Setup:** Create project → Auth is included → Install `@supabase/supabase-js` → Configure providers
- **Credentials:** Project URL, Anon Key, Service Role Key
- **Free tier:** Included with Supabase free tier (50,000 MAU)
- **Docs:** https://supabase.com/docs/guides/auth

### Kinde
- **Signup:** https://app.kinde.com/register
- **Setup:** Create business → Choose framework → Install SDK → Configure redirect URIs
- **Credentials:** Domain, Client ID, Client Secret
- **Free tier:** 10,500 MAU
- **Docs:** https://docs.kinde.com

---

## Payments

### Stripe
- **Signup:** https://dashboard.stripe.com/register
- **Setup:** Create account → Get API keys → Install `stripe` SDK → Create products in dashboard
- **Credentials:** Publishable Key, Secret Key, Webhook Signing Secret
- **Free tier:** No monthly fee, 2.9% + $0.30 per transaction
- **Docs:** https://docs.stripe.com

### Paddle
- **Signup:** https://www.paddle.com/signup
- **Setup:** Create account → Approval process (1-3 days) → Configure products → Install Paddle.js
- **Credentials:** Vendor ID, Auth Code, Public Key
- **Free tier:** No monthly fee, 5% + $0.50 per transaction (merchant of record)
- **Docs:** https://developer.paddle.com

### LemonSqueezy
- **Signup:** https://app.lemonsqueezy.com/register
- **Setup:** Create store → Create products → Install SDK → Configure webhooks
- **Credentials:** API Key, Store ID, Webhook Secret
- **Free tier:** No monthly fee, 5% + $0.50 per transaction (merchant of record)
- **Docs:** https://docs.lemonsqueezy.com

---

## Databases

### Supabase (PostgreSQL)
- **Signup:** https://supabase.com/dashboard
- **Setup:** Create project → Choose region → Database is ready immediately → Install client
- **Credentials:** Project URL, Anon Key, Service Role Key, Database Connection String
- **Free tier:** 500 MB database, 2 projects, 50K MAU auth
- **Docs:** https://supabase.com/docs

### MongoDB Atlas
- **Signup:** https://www.mongodb.com/cloud/atlas/register
- **Setup:** Create cluster → Choose M0 free tier → Create database user → Whitelist IP → Get connection string
- **Credentials:** Connection String (includes user/password)
- **Free tier:** M0 shared cluster, 512 MB storage
- **Docs:** https://www.mongodb.com/docs/atlas

### Neon (PostgreSQL)
- **Signup:** https://neon.tech
- **Setup:** Create project → Database is ready → Copy connection string → Install client
- **Credentials:** Connection String
- **Free tier:** 0.5 GB, 1 project, 100 compute hours/mo
- **Docs:** https://neon.tech/docs

### PlanetScale (MySQL)
- **Signup:** https://planetscale.com
- **Setup:** Create database → Create branch → Connect with connection string
- **Credentials:** Host, Username, Password
- **Free tier:** 1 database, 5 GB storage, 1B reads/mo
- **Docs:** https://planetscale.com/docs

### Upstash (Redis)
- **Signup:** https://console.upstash.com
- **Setup:** Create database → Choose region → Copy REST URL and token
- **Credentials:** REST URL, REST Token
- **Free tier:** 10K commands/day, 256 MB
- **Docs:** https://upstash.com/docs/redis

### Turso (SQLite)
- **Signup:** https://turso.tech
- **Setup:** Install CLI → `turso db create` → Create auth token → Copy URL
- **Credentials:** Database URL, Auth Token
- **Free tier:** 9 GB total storage, 500 databases
- **Docs:** https://docs.turso.tech

---

## Email

### Resend
- **Signup:** https://resend.com/signup
- **Setup:** Create account → Verify domain (add DNS records) → Get API key → Install SDK
- **Credentials:** API Key
- **Free tier:** 3,000 emails/mo, 1 domain
- **Docs:** https://resend.com/docs

### SendGrid
- **Signup:** https://signup.sendgrid.com
- **Setup:** Create account → Verify sender → Create API key → Install SDK
- **Credentials:** API Key
- **Free tier:** 100 emails/day
- **Docs:** https://docs.sendgrid.com

### Postmark
- **Signup:** https://postmarkapp.com/sign_up
- **Setup:** Create server → Verify sender domain → Get API token → Install SDK
- **Credentials:** Server API Token
- **Free tier:** 100 emails/mo
- **Docs:** https://postmarkapp.com/developer

### AWS SES
- **Signup:** Via AWS Console
- **Setup:** Verify domain → Request production access → Configure SMTP or API
- **Credentials:** SMTP credentials or AWS Access Key + Secret
- **Free tier:** 3,000/mo free (from EC2), $0.10/1,000 otherwise
- **Docs:** https://docs.aws.amazon.com/ses

---

## SMS & Messaging

### Twilio
- **Signup:** https://www.twilio.com/try-twilio
- **Setup:** Create account → Get phone number → Install SDK → Send messages
- **Credentials:** Account SID, Auth Token
- **Free tier:** Trial balance (~$15)
- **Docs:** https://www.twilio.com/docs

---

## Hosting & Deployment

### Vercel
- **Signup:** https://vercel.com/signup
- **Setup:** Connect GitHub repo → Auto-detect framework → Deploy
- **Credentials:** None needed for basic deploy (uses GitHub OAuth)
- **Free tier:** Hobby (personal, non-commercial), 100 GB bandwidth
- **Docs:** https://vercel.com/docs

### Netlify
- **Signup:** https://app.netlify.com/signup
- **Setup:** Connect GitHub repo → Configure build settings → Deploy
- **Credentials:** None needed for basic deploy
- **Free tier:** 100 GB bandwidth, 300 build minutes/mo
- **Docs:** https://docs.netlify.com

### Railway
- **Signup:** https://railway.app
- **Setup:** Connect GitHub → Select repo → Configure environment variables → Deploy
- **Credentials:** None needed (uses GitHub OAuth)
- **Free tier:** $5 trial credit
- **Docs:** https://docs.railway.app

### Render
- **Signup:** https://render.com
- **Setup:** Connect GitHub → Create service → Configure → Deploy
- **Credentials:** None needed for basic deploy
- **Free tier:** Free web service (sleeps after 15 min inactivity)
- **Docs:** https://render.com/docs

### Fly.io
- **Signup:** https://fly.io/app/sign-up
- **Setup:** Install flyctl CLI → `fly launch` → Configure → Deploy
- **Credentials:** Fly API Token
- **Free tier:** 3 shared-cpu-1x VMs, 3 GB persistent storage
- **Docs:** https://fly.io/docs

---

## Storage

### AWS S3
- **Signup:** Via AWS Console
- **Setup:** Create bucket → Configure CORS → Create IAM user → Get access keys
- **Credentials:** Access Key ID, Secret Access Key, Bucket Name, Region
- **Free tier:** 5 GB, 20K GET, 2K PUT (12 months)
- **Docs:** https://docs.aws.amazon.com/s3

### Cloudflare R2
- **Signup:** https://dash.cloudflare.com/sign-up
- **Setup:** Enable R2 → Create bucket → Generate API token
- **Credentials:** Account ID, Access Key ID, Secret Access Key
- **Free tier:** 10 GB storage, 10M reads/mo, 1M writes/mo, no egress fees
- **Docs:** https://developers.cloudflare.com/r2

### Uploadthing
- **Signup:** https://uploadthing.com
- **Setup:** Create app → Install SDK → Configure file router → Add upload components
- **Credentials:** API Key, App ID
- **Free tier:** 2 GB storage
- **Docs:** https://docs.uploadthing.com

---

## Monitoring & Analytics

### Sentry
- **Signup:** https://sentry.io/signup
- **Setup:** Create project → Install SDK → Configure DSN → Capture errors
- **Credentials:** DSN (Data Source Name)
- **Free tier:** 5K errors/mo, 10K performance events
- **Docs:** https://docs.sentry.io

### PostHog
- **Signup:** https://posthog.com
- **Setup:** Create project → Install snippet or SDK → Events auto-captured
- **Credentials:** Project API Key
- **Free tier:** 1M events/mo, 5K session recordings/mo
- **Docs:** https://posthog.com/docs

### Datadog
- **Signup:** https://www.datadoghq.com
- **Setup:** Create account → Install agent on servers → Configure integrations
- **Credentials:** API Key, Application Key
- **Free tier:** 5 hosts, 1-day retention
- **Docs:** https://docs.datadoghq.com

---

## Search

### Algolia
- **Signup:** https://www.algolia.com/users/sign_up
- **Setup:** Create app → Create index → Push records → Install InstantSearch SDK
- **Credentials:** Application ID, Search API Key, Admin API Key
- **Free tier:** 10K search requests/mo, 10K records
- **Docs:** https://www.algolia.com/doc

### Typesense
- **Signup:** https://cloud.typesense.org
- **Setup:** Create cluster → Create collection → Index documents → Query
- **Credentials:** API Key, Host, Port
- **Free tier:** Typesense Cloud free tier available
- **Docs:** https://typesense.org/docs

### Meilisearch
- **Signup:** https://cloud.meilisearch.com
- **Setup:** Create project → Get credentials → Install SDK → Index documents
- **Credentials:** Host, API Key
- **Free tier:** Meilisearch Cloud free plan (100K documents)
- **Docs:** https://www.meilisearch.com/docs

---

## CI/CD

### GitHub Actions
- **Signup:** Included with GitHub
- **Setup:** Create `.github/workflows/` directory → Add workflow YAML files
- **Credentials:** Automatic `GITHUB_TOKEN`, custom secrets via repository settings
- **Free tier:** 2,000 minutes/mo (free plan)
- **Docs:** https://docs.github.com/en/actions

### Vercel (CI/CD)
- **Signup:** Included with Vercel account
- **Setup:** Connect repo → Auto-deploys on push → Preview deploys on PR
- **Credentials:** None needed
- **Free tier:** Included with Hobby plan
- **Docs:** https://vercel.com/docs/deployments

---

## Maps & Location

### Google Maps
- **Signup:** https://console.cloud.google.com
- **Setup:** Enable Maps JavaScript API → Create API key → Restrict key → Install SDK
- **Credentials:** API Key
- **Free tier:** $200/mo credit (~28K map loads)
- **Docs:** https://developers.google.com/maps

### Mapbox
- **Signup:** https://account.mapbox.com/auth/signup
- **Setup:** Create account → Get access token → Install SDK
- **Credentials:** Access Token
- **Free tier:** 50K map loads/mo, 100K geocoding requests/mo
- **Docs:** https://docs.mapbox.com

---

## Push Notifications

### OneSignal
- **Signup:** https://onesignal.com
- **Setup:** Create app → Configure platform (web/mobile) → Install SDK
- **Credentials:** App ID, REST API Key
- **Free tier:** Unlimited push notifications (mobile), 10K web push subscribers
- **Docs:** https://documentation.onesignal.com

### Novu
- **Signup:** https://web.novu.co/auth/signup
- **Setup:** Create account → Install SDK → Configure notification templates
- **Credentials:** API Key, Application ID
- **Free tier:** 30K events/mo
- **Docs:** https://docs.novu.co
