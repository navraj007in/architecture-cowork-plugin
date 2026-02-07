---
name: founder-communication
description: Communication guidelines for non-technical founders. Plain English defaults, analogy-first explanations, progressive disclosure. Use when generating any user-facing architecture output.
---

# Founder Communication

Guidelines for communicating architecture decisions to non-technical founders and early-stage teams. These rules apply to all outputs unless the user explicitly requests deep technical language.

---

## Default: Plain English

- Write as if explaining to a smart person who has never written code
- Use everyday language: "database" not "persistence layer", "background job" not "async worker", "login system" not "identity provider"
- If a technical term is necessary, explain it immediately: "Redis (a fast in-memory cache — think of it as short-term memory for your app)"

## Acronym Rule

Expand every acronym on first use in every deliverable:

- API (Application Programming Interface)
- SSE (Server-Sent Events)
- CDN (Content Delivery Network)
- LLM (Large Language Model)
- MAU (Monthly Active Users)
- CI/CD (Continuous Integration / Continuous Deployment)
- SDK (Software Development Kit)
- JWT (JSON Web Token)
- CRUD (Create, Read, Update, Delete)

After the first expansion, use the acronym freely.

## Analogy-First Explanations

When introducing a concept, use an analogy before the technical definition:

| Concept | Analogy |
|---------|---------|
| Load balancer | "Like a host at a restaurant — directs customers to available tables" |
| Message queue | "Like a to-do list between two teams — one team adds tasks, the other works through them" |
| Caching | "Like keeping frequently used files on your desk instead of walking to the filing cabinet" |
| WebSocket | "Like a phone call — both sides can talk at any time, unlike email where you send and wait" |
| Vector database | "Like a librarian who understands meaning — finds related documents even if they don't share exact words" |
| API gateway | "Like a reception desk — all visitors check in here before being directed to the right department" |
| Microservices | "Like separate departments in a company — each handles its own job and communicates through email" |
| Container | "Like a shipping container — your app and everything it needs, packed so it runs the same way everywhere" |
| CI/CD pipeline | "Like an assembly line — every code change gets automatically tested and deployed" |

## Information Order

Structure every output following this order:

1. **What it does** — business outcome in one sentence
2. **Why it matters** — business impact (cost, speed, risk)
3. **How it works** — technical explanation (only as deep as needed)
4. **What it costs** — dollars and time
5. **What could go wrong** — risks in plain language

Never lead with technical implementation details. A founder reading the output should understand the business value in the first 2 sentences.

## Risk Communication

Use these severity levels consistently:

| Severity | Label | Meaning | Example |
|----------|-------|---------|---------|
| Low | "Manageable" | Standard engineering challenge, well-understood solution | "Real-time updates add some complexity but it's a solved problem" |
| Medium | "Significant" | Requires careful planning or specialized expertise | "Multi-tenant data isolation needs to be designed carefully from day one" |
| High | "Potential dealbreaker" | Could fundamentally change scope, timeline, or feasibility | "HIPAA compliance adds 2-3 months and requires specialized infrastructure" |

Always pair a risk with a mitigation: "This is significant because X, but you can manage it by Y."

## Cost Communication

- Always use ranges, never single numbers: "$50-150/month" not "$100/month"
- Always include what drives the cost up or down: "Closer to $50 if you stay on free tiers, $150 if you need production-grade monitoring"
- Always compare to something relatable: "About the cost of a nice dinner out each month" or "Less than one hour of developer time"
- Break costs into categories a founder cares about: infrastructure, third-party tools, AI/LLM usage, development

## Progressive Disclosure

Start simple. Add detail only when:

1. **The user asks** — "Can you go deeper on the database choice?"
2. **The user demonstrates technical knowledge** — if they mention specific technologies, frameworks, or patterns, match their level
3. **The decision requires it** — some architecture choices genuinely need technical context to understand the tradeoff

If in doubt, keep it simple. A founder who wants more detail will ask.

## Formatting Rules

- Use tables for comparisons (stacks, costs, options)
- Use bulleted lists for features and requirements
- Use Mermaid diagrams for architecture — never describe architecture in prose when a diagram would be clearer
- Use bold for key terms on first introduction
- Keep paragraphs short — 2-3 sentences maximum
- Use headers to break up sections — a founder should be able to scan and find what they need
