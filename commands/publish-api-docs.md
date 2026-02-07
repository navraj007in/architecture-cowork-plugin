---
description: Generate interactive API documentation from blueprint specs (Swagger UI, Redoc, AsyncAPI)
---

# /architect:publish-api-docs

## Trigger

`/architect:publish-api-docs`

## Purpose

After generating a blueprint with `/architect:blueprint`, this command takes the API artifacts (deliverable 4e — OpenAPI specs, AsyncAPI specs, Postman collections) and generates interactive, browsable API documentation. Output can be served locally, deployed to GitHub Pages, or used as static HTML files.

## Workflow

### Step 1: Check for API Artifacts

Check if a blueprint with API artifacts (deliverable 4e) exists earlier in the conversation.

If no blueprint or no API artifacts exist, respond:

> "I need API specifications to publish. Run `/architect:blueprint` first to generate your architecture with API artifacts, then come back here to create the documentation."

### Step 2: Ask Configuration

Ask the user:

> "How would you like the API docs?"
>
> - **Swagger UI + Redoc** (default) — Both viewers for your REST API, plus raw spec files
> - **Swagger UI only** — Just the interactive explorer
> - **Redoc only** — Clean, readable documentation
>
> "Where should I save them?"
> - Default: `./api-docs/` in the project directory
>
> "Want me to start a local preview server when done?" (yes/no)

### Step 3: Delegate to API Docs Publisher Agent

Pass the following to the **api-docs-publisher** agent:

- All OpenAPI specs from deliverable 4e
- All AsyncAPI specs (if any)
- All Postman collections
- GraphQL schemas (if any)
- Output format preference
- Output directory
- Whether to start preview server

### Step 4: Print Summary

```
API documentation published!

| Doc Type | Service | URL / Path |
|----------|---------|------------|
| Swagger UI | api-server | api-docs/swagger-ui.html |
| Redoc | api-server | api-docs/redoc.html |
| AsyncAPI | worker | api-docs/asyncapi.html |
| Raw OpenAPI | api-server | api-docs/openapi/api-server.yaml |
| Postman | api-server | api-docs/postman/api-server.postman.json |

Preview: npx serve api-docs/ -p 8080
Deploy: push api-docs/ to GitHub Pages, Vercel, or Netlify
Import: drag api-server.postman.json into Postman for API testing
```

## Output Rules

- Use the **founder-communication** skill for tone
- Always check for API artifacts first
- Always generate an index page linking all docs
- Report clear paths for all generated files
- Do NOT include the CTA footer
