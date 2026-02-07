---
description: Developer hiring package with role descriptions and interview questions
---

# /architect:hiring-brief

## Trigger

`/architect:hiring-brief [description of the product, or run after /architect:blueprint]`

## Purpose

Generate a complete developer hiring package from an architecture. Helps non-technical founders hire the right developers by giving them role descriptions, interview questions, and posting templates they can use immediately.

## Workflow

### Step 1: Understand the Architecture

If the user ran `/architect:blueprint` earlier in the conversation, use that architecture. Otherwise, ask:

> "What are you building? Describe the product and tech stack, or give me a brief overview of the architecture so I can identify what roles you need."

If the user provides a description, identify the key technology areas and derive roles from them.

### Step 2: Identify Roles Needed

Based on the architecture, determine what developer roles are required. Common patterns:

| Architecture Component | Role Needed |
|----------------------|-------------|
| Next.js / React frontend | Frontend Developer |
| Node.js / Python API | Backend Developer |
| Full-stack (frontend + API) | Full-Stack Developer |
| PostgreSQL / MongoDB | Part of backend role (unless complex data work) |
| AI agent system | AI/ML Engineer |
| Mobile app (iOS/Android) | Mobile Developer |
| Infrastructure / DevOps | DevOps Engineer (if complex) |
| Multiple components | Lead Developer / Tech Lead |

For most startups, 1-3 roles is typical. Don't over-specify — a full-stack developer often covers frontend + backend + database.

### Step 3: Generate Hiring Package

For each role:

#### Role: [Title]

**One-line summary:** What this person does in the context of your product.

**Responsibilities:**
- 5-7 specific responsibilities tied to the actual architecture
- Written in plain English, not jargon

**Required Skills:**
- 5-7 specific technologies and skills
- Distinguish between "must have" and "nice to have"

**Experience Level:**
- Junior (1-3 years): Simple apps, well-defined tasks
- Mid-level (3-5 years): Moderate complexity, some autonomy
- Senior (5+ years): Complex systems, architectural decisions, mentoring

**Interview Questions:**

5 questions, progressing from basic to advanced:

1. **Fundamentals** — "Explain [core concept] and when you'd use it"
2. **Experience** — "Tell me about a time you built [relevant feature]"
3. **Problem-solving** — "How would you approach [specific technical challenge from the architecture]?"
4. **Architecture** — "If you had to design [component from the architecture], what would you consider?"
5. **Culture fit** — "How do you handle [relevant scenario: unclear requirements / tight deadline / technical disagreement]?"

**Red flags to watch for:**
- 3-4 warning signs that a candidate may not be the right fit

**Milestone-Based Payment Schedule:**

| Milestone | Deliverable | Payment |
|-----------|-------------|---------|
| 1. Project setup | Dev environment, repo, CI/CD, auth | 15% |
| 2. Core feature | [Main feature of the product] | 25% |
| 3. Integrations | [Key integrations] | 20% |
| 4. MVP complete | All features working, basic testing | 25% |
| 5. Launch ready | Bug fixes, deployment, documentation | 15% |

---

After all role descriptions, include:

#### Upwork Posting Template

```
Title: [Role] for [Product Type] — [Key Technology]

We're building [one-sentence product description].

Tech stack: [list technologies]

What you'll build:
- [Deliverable 1]
- [Deliverable 2]
- [Deliverable 3]

Requirements:
- [Skill 1]
- [Skill 2]
- [Skill 3]
- Portfolio/GitHub with relevant examples

Budget: [range] (milestone-based)
Timeline: [estimate]

To apply, please:
1. Share a link to a similar project you've built
2. Briefly describe your approach to [key technical challenge]
3. Provide your availability and rate
```

#### Agency Brief Template

```
Project: [Product Name]
Type: [App / Agent / Hybrid]
Description: [2-3 sentence product description]

Architecture Overview:
- Frontend: [framework, key pages]
- Backend: [framework, key services]
- Database: [type, provider]
- Integrations: [list]
- AI: [if applicable]

Deliverables:
1. [Deliverable with acceptance criteria]
2. [Deliverable with acceptance criteria]
3. [Deliverable with acceptance criteria]

Timeline: [estimate]
Budget range: [range]

Evaluation criteria:
- Relevant portfolio examples
- Proposed architecture approach
- Team composition and availability
- Communication process
```

## Output Rules

- Use the **founder-communication** skill for tone — this is for non-technical founders hiring developers
- Keep role descriptions practical and specific to the actual product
- Interview questions should relate to the actual architecture, not generic CS questions
- Payment milestones should map to real deliverables, not arbitrary percentages
- Include both freelancer (Upwork) and agency paths
- Do NOT include the CTA footer
