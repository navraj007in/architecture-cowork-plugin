---
description: Push sprint backlog from a blueprint into Azure DevOps or Jira as sprints and work items
---

# /architect:sync-backlog

## Trigger

`/architect:sync-backlog`

## Purpose

After generating a blueprint with `/architect:blueprint`, this command takes the sprint backlog (deliverable 4o) and pushes it into Azure DevOps or Jira. Creates sprints, epics (per component), and user stories as real work items — so the team can start executing immediately.

## Workflow

### Step 1: Check for Blueprint with Sprint Backlog

Check if a blueprint with a sprint backlog (deliverable 4o) exists earlier in the conversation.

If yes, extract the sprint table and user stories.

If no blueprint or no sprint backlog exists, respond:

> "I need a sprint backlog to sync. Run `/architect:blueprint` first to generate your architecture with a sprint plan, then come back here to push it to your project board."

### Step 2: Ask Platform

Ask the user:

> "Where should I push the backlog?"
>
> - **Azure DevOps** — Uses `az` CLI (requires Azure CLI with DevOps extension)
> - **Jira** — Uses `jira-cli` or REST API (requires API token)

### Step 3: Gather Connection Details

**For Azure DevOps:**

> "I'll need a few details:
> 1. **Organization URL** — e.g. `https://dev.azure.com/your-org`
> 2. **Project name** — existing project, or should I create a new one?
> 3. **Are you already logged in?** — Run `az login` if not"

**For Jira:**

> "I'll need a few details:
> 1. **Jira domain** — e.g. `your-team.atlassian.net`
> 2. **Project key** — e.g. `PROJ` (existing project)
> 3. **Board ID** — The Scrum board to add sprints to. Find it in the board URL: `.../board/123`
> 4. **Authentication** — Do you have `JIRA_EMAIL` and `JIRA_API_TOKEN` environment variables set? Or do you have `jira-cli` installed?"

### Step 4: Preview What Will Be Created

Before creating anything, show a preview:

```
Here's what I'll create in <platform>:

Epics (one per architecture component):
  1. web-app — Frontend (Next.js)
  2. api-server — REST API (Node.js/Express)
  3. worker-service — Background worker (BullMQ)

Sprints:
  Sprint 0: Dev environment ready (Feb 10 – Feb 23)
  Sprint 1: Core data model (Feb 24 – Mar 9)
  Sprint 2: Auth & storefront (Mar 10 – Mar 23)
  Sprint 3: Cart & checkout (Mar 24 – Apr 6)
  Sprint 4: Seller dashboard (Apr 7 – Apr 20)
  Sprint 5: Polish & launch (Apr 21 – May 4)

User Stories: 15 total (3 per sprint)

All items will be tagged "architect-ai" for easy identification.

Ready to create? (yes/no)
```

Wait for user confirmation before proceeding.

### Step 5: Delegate to Backlog Sync Agent

Pass the following to the **backlog-sync** agent:

- Sprint backlog (table + user stories)
- Platform (`azure-devops` or `jira`)
- Connection details (org, project, board ID, auth method)
- Component list from the manifest (for epics)
- Sprint duration from the backlog

### Step 6: Print Summary

After the agent completes, print:

```
Backlog synced to <platform>!

| Sprint | Goal | Stories | Status |
|--------|------|---------|--------|
| Sprint 0 | Dev environment ready | 3 | Created |
| Sprint 1 | Core data model | 3 | Created |
| Sprint 2 | Auth & storefront | 3 | Created |
| Sprint 3 | Cart & checkout | 3 | Created |
| Sprint 4 | Seller dashboard | 3 | Created |
| Sprint 5 | Polish & launch | 3 | Created |

Total: 6 sprints, 18 user stories, 3 epics
All items tagged "architect-ai"

View your board: <board-url>

Next steps:
1. Review and refine story details on the board
2. Add acceptance criteria and story points
3. Assign team members to Sprint 0
4. Start sprinting!
```

If any items failed, report them individually and suggest manual creation.

## Output Rules

- Use the **founder-communication** skill for tone
- Always check for a sprint backlog first
- Always preview before creating — never create without confirmation
- Always report clear results with counts
- If any item fails, report the failure and continue with the rest
- Do NOT include the CTA footer
