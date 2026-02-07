---
name: product-type-detector
description: Detects product type from user requirements to trigger domain-specific architecture depth sections
version: 1.0.0
author: Navraj Singh
tags: [architecture, detection, classification]
---

# Product Type Detector

**Purpose**: Automatically identifies the product type(s) from user requirements to trigger appropriate domain-specific architecture depth sections.

**When to Use**: Internally by architecture-methodology skill during blueprint generation. Never invoke directly.

---

## Product Type Detection Rules

Analyze the user's requirements and detect ALL applicable product types. A single product can match multiple types.

### 1. Real-time Collaboration

**Triggers**:
- Keywords: "real-time", "live updates", "chat", "messaging", "presence", "collaboration", "whiteboard", "cursor sharing", "co-editing", "multiplayer"
- Features: WebSockets, Server-Sent Events, presence indicators, typing indicators, read receipts
- Examples: Slack clone, Figma clone, Google Docs alternative, team chat, collaborative whiteboard

**Detection Logic**:
```
IF (mentions "real-time" OR "live" OR "chat" OR "messaging" OR "collaboration")
AND (mentions "users see updates immediately" OR "WebSocket" OR "presence" OR "typing indicator")
THEN product_type.includes("real-time-collaboration")
```

**Depth Sections to Add**:
- Message Delivery Model (ordering, offline delivery, fanout)
- Presence & Typing Indicators (WebSocket heartbeats, last seen)
- Read Receipts & Message Status (delivery confirmation)
- Conflict Resolution (for collaborative editing)

---

### 2. Multi-tenant B2B SaaS

**Triggers**:
- Keywords: "multi-tenant", "workspace", "organization", "account", "B2B", "SaaS", "each company", "per customer", "tenant"
- Features: Workspace/organization model, SSO/SAML, custom domains, white-labeling, per-tenant billing
- Examples: Project management tool for agencies, CRM for sales teams, analytics platform for enterprises

**Detection Logic**:
```
IF (mentions "multi-tenant" OR "workspace" OR "each company" OR "B2B" OR "organization")
OR (mentions "SSO" OR "SAML" OR "custom domain per customer" OR "white-label")
THEN product_type.includes("multi-tenant-saas")
```

**Depth Sections to Add**:
- Tenant Isolation Design (shared DB with RLS vs separate DBs)
- Tenant Context Propagation (middleware, JWT claims)
- Per-tenant Feature Flags & Quotas
- Tenant-scoped Data Storage (S3 prefixes, database sharding)

---

### 3. File Upload/Storage

**Triggers**:
- Keywords: "file upload", "file sharing", "document storage", "media library", "attachments", "images", "videos", "PDFs"
- Features: File upload, virus scanning, image optimization, CDN delivery, download links
- Examples: Google Drive clone, media asset manager, document management, file sharing platform

**Detection Logic**:
```
IF (mentions "file upload" OR "file sharing" OR "document" OR "media" OR "attachment" OR "storage")
AND (mentions "users can upload" OR "file management" OR "asset library")
THEN product_type.includes("file-upload-storage")
```

**Depth Sections to Add**:
- File Upload Threat Model (malware, CSRF, size limits)
- Virus Scanning Pipeline (ClamAV, S3 quarantine bucket)
- Image Optimization (resizing, WebP conversion, thumbnails)
- Secure Download URLs (signed URLs, expiration, rate limiting)

---

### 4. E-commerce/Marketplace

**Triggers**:
- Keywords: "e-commerce", "marketplace", "shopping", "cart", "checkout", "payments", "products", "inventory", "orders"
- Features: Product catalog, shopping cart, payment processing, order management, inventory tracking
- Examples: Shopify clone, Etsy alternative, booking platform, subscription service

**Detection Logic**:
```
IF (mentions "e-commerce" OR "marketplace" OR "shopping" OR "cart" OR "checkout" OR "payment" OR "stripe")
OR (mentions "products" AND "buy" AND "sell")
THEN product_type.includes("ecommerce-marketplace")
```

**Depth Sections to Add**:
- Payment Flow & Idempotency (Stripe webhooks, duplicate charges)
- Inventory Management (stock tracking, race conditions)
- Order State Machine (pending → paid → fulfilled → shipped)
- Tax & Compliance (sales tax, VAT, invoicing)

---

### 5. AI Agent Application

**Triggers**:
- Keywords: "AI agent", "LLM", "chatbot", "Claude", "GPT", "OpenAI", "Anthropic", "tool calling", "function calling", "RAG", "embeddings"
- Features: LLM integration, tool/function calling, vector search, prompt engineering, token management
- Examples: Customer support chatbot, AI research assistant, code review agent, document Q&A

**Detection Logic**:
```
IF (mentions "AI" OR "LLM" OR "agent" OR "Claude" OR "GPT" OR "chatbot")
AND (mentions "tool calling" OR "function calling" OR "RAG" OR "embeddings" OR "knowledge base")
THEN product_type.includes("ai-agent")
```

**Depth Sections to Add**:
- Agent Orchestration Pattern (ReAct, Chain-of-Thought, multi-agent)
- Tool Definitions & Schemas (JSON schema for each tool)
- Token Cost Modeling (input + output tokens per request)
- Guardrails & Safety (content filters, PII detection, hallucination mitigation)
- Memory Strategy (conversation context, vector memory, user profiles)

---

### 6. Content Platform

**Triggers**:
- Keywords: "blog", "CMS", "publishing", "posts", "articles", "content management", "SEO", "social media"
- Features: Rich text editor, publishing workflow, SEO optimization, content moderation, analytics
- Examples: Medium clone, blogging platform, social network, forum, newsletter platform

**Detection Logic**:
```
IF (mentions "blog" OR "CMS" OR "publishing" OR "posts" OR "articles" OR "content")
AND (mentions "SEO" OR "rich text" OR "editor" OR "publishing workflow")
THEN product_type.includes("content-platform")
```

**Depth Sections to Add**:
- Publishing Workflow (draft → review → published)
- SEO Architecture (meta tags, sitemaps, Open Graph)
- Content Moderation (spam detection, profanity filters)
- Rich Text Storage (HTML sanitization, markdown vs structured data)

---

## Output Format

Return detected product types as array:

```json
{
  "product_types": [
    "real-time-collaboration",
    "multi-tenant-saas"
  ],
  "confidence": {
    "real-time-collaboration": "high",
    "multi-tenant-saas": "medium"
  },
  "reasoning": {
    "real-time-collaboration": "User mentioned 'real-time chat' and 'WebSocket' explicitly",
    "multi-tenant-saas": "Mentioned 'workspace' and 'each company gets their own account'"
  }
}
```

---

## Usage Example

**Input**:
```
User: "Build a team collaboration tool like Slack. Each company gets their own workspace with channels and DMs. Real-time messaging with typing indicators. File sharing. 100 companies, 10-50 users each."
```

**Output**:
```json
{
  "product_types": [
    "real-time-collaboration",
    "multi-tenant-saas",
    "file-upload-storage"
  ],
  "confidence": {
    "real-time-collaboration": "high",
    "multi-tenant-saas": "high",
    "file-upload-storage": "medium"
  },
  "reasoning": {
    "real-time-collaboration": "Explicitly mentions 'real-time messaging' and 'typing indicators'",
    "multi-tenant-saas": "Each company gets workspace (multi-tenant pattern)",
    "file-upload-storage": "Includes file sharing feature"
  }
}
```

---

## Integration with Architecture Methodology

The architecture-methodology skill will:
1. Call this detector after gathering initial requirements
2. Receive list of detected product types
3. For each detected type, inject corresponding depth sections into blueprint
4. Prioritize depth sections by confidence score

**Example Flow**:
```
User submits requirements
  ↓
Architecture methodology gathers info via Essential Questions
  ↓
Product type detector analyzes requirements
  ↓
Detector returns: ["real-time-collaboration", "multi-tenant-saas"]
  ↓
Architecture methodology injects:
  - Message Delivery Model section (real-time)
  - Tenant Isolation Design section (multi-tenant)
  ↓
Blueprint generated with domain-specific depth
```

---

## Edge Cases

**Case 1: No product type detected**
- Action: Generate standard blueprint without specialized depth sections
- Note: Rare, most products match at least one type

**Case 2: Multiple product types detected**
- Action: Include depth sections for ALL detected types
- Priority: Order by confidence score (high → medium → low)

**Case 3: Conflicting depth sections**
- Example: AI agent + real-time collaboration (both need different WebSocket patterns)
- Action: Merge sections and note trade-offs in "Architecture Decisions" section

---

## Version History

- **1.0.0** (2026-02-07): Initial release with 6 product types
