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

**First**, check `architecture-output/_state.json`. If it exists, read it in full — it provides instant access to `project`, `tech_stack`, `components`, `design`, `entities`, and `personas` without reading larger files. Use its values directly where available; fall back to SDL (check `solution.sdl.yaml` first; if absent, read `sdl/README.md` then the relevant module files) only for detail not in `_state.json`.

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

### Step 5: Docs Publish (Optional)

After generating the docs, silently probe both Confluence (`list_spaces limit:1`) and Notion (`notion_search query:"test" page_size:1`) to check which are connected.

**If Confluence is connected**, offer:
> "Confluence is connected. Publish the API reference to your team space as well? Reply with the space key (e.g. `ARCH`), a Notion parent page ID, or `skip`."

- Space key → delegate to **confluence-publisher** with `artifact:"api-docs"`, `projectName`, `spaceKey`, `projectDir`

**If Notion is connected** (and Confluence was not, or user prefers Notion):
> "Notion is connected. Publish the API reference to Notion? Reply with a parent page ID or `skip`."

- Page ID → delegate to **notion-publisher** with `artifact:"api-docs"`, `projectName`, `parentPageId`, `projectDir`

**If both connected**, offer both options in one message.
**If neither**, skip silently.

### Final Step: Log Activity

After the export completes, append one line to `architecture-output/_activity.jsonl`:

```json
{"ts":"<ISO-8601>","phase":"publish-api-docs","outcome":"completed","files":[],"summary":"API docs published: <N> specs rendered (<formats>) to <output-dir>."}
```

List all published file paths in the `files` array.

### Signal Completion

Emit the completion marker:

```
[API_DOCS_DONE]
```

This ensures the api-docs phase is marked as complete in the project state.

## Error Handling

### Missing API Contracts

If no OpenAPI or GraphQL contracts exist:
> "I need API contracts to document. Run `/architect:scaffold` (which generates contracts in Step 3.7), then come back here."

### Malformed OpenAPI Schema

If an OpenAPI/GraphQL contract has syntax errors:
- Report: "Contract [X] is malformed. Regenerate via `/architect:scaffold`."
- Skip that contract, continue with others

### Docs Server Unreachable

If the user has specified a docs server endpoint (e.g., Swagger UI, ReDoc) and it's unreachable:
- Report: "Docs server at [URL] is unreachable. Check network and endpoint."
- Continue with local documentation generation

### Unable to Write Documentation Files

If `docs/` directory cannot be created due to permissions:
- Stop execution
- Report: "Cannot write documentation files: [error]. Check file permissions."
- Do NOT emit completion marker

## Output Rules

- Use the **founder-communication** skill for tone
- Always check for API artifacts first
- Always generate an index page linking all docs
- Report clear paths for all generated files
- Do NOT include the CTA footer
