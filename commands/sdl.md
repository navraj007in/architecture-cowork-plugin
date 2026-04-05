---
description: Generate, validate, diff, or browse SDL (Solution Design Language) architecture specifications
---

# /architect:sdl

## Trigger

`/architect:sdl [mode] [optional YAML or description]`

Modes: `generate` (default), `validate`, `diff`, `template`

## Purpose

Work directly with SDL — the structured YAML specification that captures architecture decisions. Use this command to generate SDL from a conversation, validate existing SDL, compare two versions, or start from a template.

## Workflow

## Quick Navigation

[Detect Mode](#detect-mode) · [Mode 1: Generate](#mode-1-generate-sdl) · [Mode 2: Validate](#mode-2-validate-sdl) · [Mode 3: Diff](#mode-3-diff-sdl) · [Mode 4: Template](#mode-4-template)

### Detect Mode

Determine the mode from the user's input:

- **No mode specified or `generate`** — Generate SDL from conversation context or description
- **`validate`** — User provides SDL YAML to validate
- **`diff`** — User provides two SDL documents to compare
- **`template`** or **`templates`** — Browse and customize starter templates

---

### Mode 1: Generate SDL

Using the **sdl-knowledge** skill:

1. **Check for existing context:**
   - If a system manifest was built in this conversation, use it as input
   - If a `.arch0-context.json` exists, load it
   - If the user provided a description, use it to gather requirements
   - If no context exists, ask: "What are you building? Describe your product idea."

2. **Gather minimum requirements** (if not already known):
   - What is it? (name, description)
   - Who uses it? (personas with goals)
   - What stage? (MVP / Growth / Enterprise)
   - What stack? (or let us recommend)
   - Where is it hosted? (cloud platform)

3. **Map to SDL** using the manifest-to-SDL mapping from the **sdl-knowledge** skill:
   - Set all required sections
   - Include only optional sections that have data
   - Let normalizer defaults handle the rest
   - Validate against the 5 conditional rules
   - **Derive `dependsOn[]` for every component in `architecture.projects`** — list the names of other components it calls plus external integrations it uses. Rules:
     - Frontend → every backend/API service it calls
     - Backend/service → other backend services it calls + external integration names (e.g. `["stripe", "sendgrid"]`)
     - Lambda/worker → the service or queue it reads from and any downstream service it invokes
     - Shared lib → `[]`
     - Always set the field explicitly — never omit it, even when the array is empty
     - Use the component's SDL `name` as the identifier; external providers in lowercase (e.g. `"razorpay"`, `"anthropic"`)

4. **Save the SDL file to the project root directory:**
   - Write the file as `solution.sdl.yaml` in the project root (current working directory)
   - Do NOT place it inside any `architecture/`, `artifacts/`, or `.arch0/` subfolder
   - If a `solution.sdl.yaml` already exists, confirm before overwriting
   - Also display the SDL as a YAML code block in the conversation:

```yaml
# SDL generated for {solution.name}
sdlVersion: "1.1"
# ... complete SDL document
```

   - Confirm: "SDL saved to `./solution.sdl.yaml`"

5. **Report validation summary:**

**Validation Summary**

| Field | Value |
|-------|-------|
| Architecture | {style} |
| Projects | {count} |
| Estimated Cost | {range} |
| Artifacts | {count} |
| Warnings | {count} |

6. **If warnings exist**, list each:

> **Warning:** {message}
> **Recommendation:** {recommendation}

7. **Offer next steps:**
   - "Run `/architect:blueprint` to generate a full architecture blueprint from this SDL"
   - "Edit the SDL above and run `/architect:sdl validate` to re-check"

8. **Update `architecture-output/_state.json`** — after saving the SDL file, merge project context into the state:
   - Read existing `architecture-output/_state.json` (or start with `{}` if missing)
   - Extract `solution`, `architecture`, `data`, `auth`, `deployment` sections from the SDL
   - Write back merging only `project` and `tech_stack` fields:
     ```json
     {
       "project": { "name": "...", "description": "...", "stage": "..." },
       "tech_stack": {
         "frontend": ["<framework>"],
         "backend": ["<framework>"],
         "database": "<primary db>",
         "auth": "<identityProvider>",
         "deployment": "<cloud>"
       }
     }
     ```
   - Follow the write rules in CLAUDE.md — do NOT overwrite fields owned by other commands

9. **Log Activity** — append one line to `architecture-output/_activity.jsonl`:

```json
{"ts":"<ISO-8601>","phase":"sdl","outcome":"completed","files":["solution.sdl.yaml"],"summary":"SDL generated for <project-name>: <architecture-style>, <N> components, <N> artifacts."}
```

---

### Mode 2: Validate SDL

1. **Accept SDL YAML** from the user (pasted in a code block or provided as context)

2. **Parse** — check YAML syntax:
   - If parse fails, report the error with line/column if available
   - Provide fix suggestion

3. **Validate** — check against the SDL v1.1 schema:
   - Check all required fields
   - Validate all enum values
   - Check the 5 conditional rules
   - If validation fails, report all errors:

**SDL validation failed** ({count} error(s))

| # | Code | Path | Message | Fix |
|---|------|------|---------|-----|
| 1 | {code} | {path} | {message} | {fix} |

4. **Normalize** — apply the 15 default rules mentally and report what would be inferred:

**Normalized Defaults** (auto-inferred if not set):

| Field | Inferred Value | Rule |
|-------|---------------|------|
| `deployment.runtime.frontend` | `vercel` | Cloud → runtime mapping |
| `backend[0].orm` | `prisma` | nodejs + postgres |
| ... | ... | ... |

5. **Detect warnings** — check the 4 warning conditions:
   - Report any warnings with recommendations

6. **Report validation summary** (same as Mode 1)

7. If valid: "SDL is valid and ready to use."

---

### Mode 3: Diff SDL

1. **Accept two SDL documents** from the user:
   - Labeled as "Version A" and "Version B", or "before" and "after"
   - Can be pasted in two code blocks, or referenced from files

2. **Parse and validate both** — both must be valid SDL

3. **Compare structurally:**
   - Deep recursive comparison
   - Named array matching (match personas, projects, services by `name` field, not index)
   - Report changes as `added`, `removed`, or `changed`

4. **Output diff:**

**SDL Diff: {solution.name}**

| Path | Change | Old Value | New Value |
|------|--------|-----------|-----------|
| `architecture.style` | changed | `modular-monolith` | `microservices` |
| `product.personas[name=Admin]` | added | — | `{name: Admin, ...}` |
| `data.cache` | removed | `{type: redis}` | — |

**Summary:**
- architecture: 1 changed
- product: 1 added
- data: 1 removed
- **Total: 3 changes**

5. **Highlight impact:**
   - Flag changes that affect conditional rules (e.g., switching to microservices without services)
   - Note if a warning would be triggered by the new version

---

### Mode 4: Template

1. **Show template index:**

| # | ID | Name | Stage | Stack |
|---|---|---|---|---|
| 1 | `saas-starter` | SaaS Starter | MVP | Next.js, Node.js, Postgres, Auth0, Vercel |
| 2 | `ecommerce` | E-Commerce Platform | Growth | Microservices, Postgres, AWS, Cognito |
| 3 | `mobile-backend` | Mobile App Backend | MVP | React Native, Node.js, Firebase, Railway |
| 4 | `internal-tool` | Internal Tool | MVP | Vue, Python FastAPI, Entra ID, Azure |
| 5 | `api-first` | API-First Platform | Growth | Go, DynamoDB, AWS |
| 6 | `ai-product` | AI Product / RAG API | MVP | Python FastAPI, Postgres, AWS |
| 7 | `marketplace` | Two-Sided Marketplace | MVP | .NET 8, Stripe Connect, AWS |
| 8 | `admin-dashboard` | Admin Dashboard | MVP | React, Node.js, Railway |
| 9 | `saas-subscription` | SaaS with Stripe Billing | MVP | Next.js, Vercel, Stripe |
| 10 | `realtime-collab` | Real-Time Collaboration | MVP | React, Node.js, Redis, Fly.io |

2. **If the user specified a template** (by name or number), output the full template YAML from `references/sdl-templates.md`

3. **Offer customization:**
   - "Want me to customize this template? Tell me what to change (name, stack, cloud, auth, etc.)"
   - Apply changes to the template and re-validate

4. **Report validation summary** for the selected template

---

## File Output Location

- **Always save generated SDL to the project root directory** as `solution.sdl.yaml`
- The project root is the current working directory (where the user ran the command)
- Never nest the SDL file inside `architecture/`, `artifacts/`, `output/`, or any other subfolder
- For templates: save as `solution.sdl.yaml` in the project root when the user confirms a template selection
- For validate/diff modes: no file output needed (read-only operations)

## Output Rules

- Follow the **founder-communication** skill for tone
- Always output SDL inside triple-backtick yaml code blocks
- Always report the validation summary table after SDL output
- List warnings prominently with recommendations
- List errors in a table with fix suggestions
- Keep explanations concise — the SDL speaks for itself
