---
name: sync-backlog
description: Sync sprint backlog from architecture blueprint to project management tools (Linear, Jira, GitHub Issues, Asana, ClickUp). Creates issues/tasks with user stories, acceptance criteria, priorities, and sprint assignments.
---

# Backlog Sync Tool

Push your architecture blueprint's **sprint backlog** to project management tools for immediate sprint planning and development.

**Perfect for**: Sprint planning, team collaboration, task tracking, agile workflows

---

## When to Use This Skill

Use this skill when you need to:
- Start sprint planning immediately after blueprinting
- Share tasks with development team in their preferred tool
- Track progress against architecture plan
- Sync blueprint updates with existing project board
- Export backlog for clients or stakeholders
- Integrate architecture planning with agile workflow

**Input**: Architecture blueprint (Section 15: Sprint Backlog)
**Output**: Issues/tasks created in Linear, Jira, GitHub, Asana, or ClickUp

---

## Supported Platforms

### 1. Linear (Recommended for Startups/Agencies)

**Why Linear**:
- Best developer experience (keyboard shortcuts, fast UI)
- Excellent GitHub integration
- Built-in roadmaps and cycles
- Free for small teams (<10 members)

**What's Created**:
- **Projects**: One per sprint (Sprint 0, Sprint 1, etc.)
- **Issues**: Each user story becomes an issue
- **Labels**: Priority (High/Medium/Low), Type (Feature/Bug/Tech Debt)
- **Estimates**: Story points from blueprint
- **Assignees**: Can auto-assign or leave unassigned
- **Cycles**: Map sprints to Linear cycles (2-week sprints)

**API Requirements**:
- Linear API key (get from: https://linear.app/settings/api)
- Team ID
- Workspace ID (auto-detected)

### 2. GitHub Issues (Recommended for Open Source)

**Why GitHub Issues**:
- Free and unlimited
- Integrated with code repository
- Familiar to all developers
- Works with GitHub Projects for boards

**What's Created**:
- **Milestones**: One per sprint
- **Issues**: Each user story becomes an issue
- **Labels**: Priority, Sprint, Type
- **Projects**: Optional - create GitHub Project board
- **Assignees**: Can auto-assign to repo collaborators

**API Requirements**:
- GitHub personal access token (classic or fine-grained)
- Repository name (e.g., `owner/repo`)

### 3. Jira (Recommended for Enterprise)

**Why Jira**:
- Industry standard for enterprise
- Advanced workflow customization
- Comprehensive reporting
- Integrates with Confluence, Bitbucket

**What's Created**:
- **Epics**: One per major feature area
- **Stories**: Each user story becomes a Jira story
- **Sprints**: Map blueprint sprints to Jira sprints
- **Story Points**: From blueprint estimates
- **Labels**: Priority, Component, Type

**API Requirements**:
- Jira Cloud instance URL (e.g., `yourcompany.atlassian.net`)
- Email address
- API token (get from: https://id.atlassian.com/manage-profile/security/api-tokens)
- Project key (e.g., `PROJ`)

### 4. Asana (Recommended for Non-Technical Teams)

**Why Asana**:
- Simple, visual interface
- Great for cross-functional teams
- Timeline view for planning
- Free for basic features

**What's Created**:
- **Projects**: One per sprint
- **Tasks**: Each user story becomes a task
- **Sections**: Group by feature area
- **Tags**: Priority, Sprint, Type
- **Custom Fields**: Story points, status

**API Requirements**:
- Asana personal access token
- Workspace ID
- Project ID (or create new project)

### 5. ClickUp (Recommended for Agencies)

**Why ClickUp**:
- All-in-one (tasks, docs, chat, goals)
- Highly customizable
- Great for client projects
- Free tier is generous

**What's Created**:
- **Lists**: One per sprint
- **Tasks**: Each user story
- **Custom Fields**: Story points, priority, sprint
- **Tags**: Feature area, type
- **Assignees**: Team members

**API Requirements**:
- ClickUp API token
- Space ID
- List ID (or create new list)

---

## How It Works

### Step 1: Parse Sprint Backlog from Blueprint

Extract from **Section 15: Sprint Backlog**:

```markdown
## Sprint 0: Project Setup & Infrastructure (Week 1)

**Goal**: Production-ready foundation

### User Stories

#### US-0.1: Developer can deploy to production
**Priority**: High
**Story Points**: 5

**Description**: Set up CI/CD pipeline so any developer can deploy code to production with a single command.

**Acceptance Criteria**:
- [ ] GitHub Actions workflow configured
- [ ] Deploys on push to `main` branch
- [ ] Automated tests run before deploy
- [ ] Deploy to Vercel (frontend) and Railway (backend)
- [ ] Environment variables configured
- [ ] Can rollback to previous version

**Technical Notes**:
- Use GitHub Actions for CI/CD
- Vercel for frontend (auto-deploy)
- Railway for backend workers
- Store secrets in GitHub Secrets

---

#### US-0.2: Database is provisioned and migrations run
**Priority**: High
**Story Points**: 3

**Description**: Set up PostgreSQL database with Prisma ORM and run initial migration.

**Acceptance Criteria**:
- [ ] Supabase project created
- [ ] Database connection string in .env
- [ ] Prisma schema matches blueprint
- [ ] Initial migration applied
- [ ] Seed data loaded
- [ ] Can query database from app

**Technical Notes**:
- Use Supabase free tier
- Prisma for ORM
- RLS policies for multi-tenancy

[... more user stories ...]
```

### Step 2: Structure Data for Target Platform

**Linear Format**:
```json
{
  "title": "US-0.1: Developer can deploy to production",
  "description": "Set up CI/CD pipeline so any developer can deploy code to production with a single command.\n\n**Acceptance Criteria**:\n- [ ] GitHub Actions workflow configured\n- [ ] Deploys on push to `main` branch\n- [ ] Automated tests run before deploy\n- [ ] Deploy to Vercel (frontend) and Railway (backend)\n- [ ] Environment variables configured\n- [ ] Can rollback to previous version\n\n**Technical Notes**:\n- Use GitHub Actions for CI/CD\n- Vercel for frontend (auto-deploy)\n- Railway for backend workers\n- Store secrets in GitHub Secrets",
  "priority": 1,
  "estimate": 5,
  "labelIds": ["<high-priority-label-id>", "<infrastructure-label-id>"],
  "projectId": "<sprint-0-project-id>",
  "teamId": "<team-id>"
}
```

**GitHub Issues Format**:
```json
{
  "title": "US-0.1: Developer can deploy to production",
  "body": "**Priority**: High\n**Story Points**: 5\n\n**Description**: Set up CI/CD pipeline so any developer can deploy code to production with a single command.\n\n**Acceptance Criteria**:\n- [ ] GitHub Actions workflow configured\n- [ ] Deploys on push to `main` branch\n- [ ] Automated tests run before deploy\n- [ ] Deploy to Vercel (frontend) and Railway (backend)\n- [ ] Environment variables configured\n- [ ] Can rollback to previous version\n\n**Technical Notes**:\n- Use GitHub Actions for CI/CD\n- Vercel for frontend (auto-deploy)\n- Railway for backend workers\n- Store secrets in GitHub Secrets",
  "labels": ["Sprint 0", "Priority: High", "Type: Infrastructure"],
  "milestone": "Sprint 0",
  "assignees": []
}
```

**Jira Format**:
```json
{
  "fields": {
    "project": { "key": "PROJ" },
    "summary": "US-0.1: Developer can deploy to production",
    "description": "Set up CI/CD pipeline so any developer can deploy code to production with a single command.\n\nh3. Acceptance Criteria\n* GitHub Actions workflow configured\n* Deploys on push to main branch\n* Automated tests run before deploy\n* Deploy to Vercel (frontend) and Railway (backend)\n* Environment variables configured\n* Can rollback to previous version\n\nh3. Technical Notes\n* Use GitHub Actions for CI/CD\n* Vercel for frontend (auto-deploy)\n* Railway for backend workers\n* Store secrets in GitHub Secrets",
    "issuetype": { "name": "Story" },
    "priority": { "name": "High" },
    "customfield_10016": 5,
    "labels": ["sprint-0", "infrastructure"],
    "sprint": "<sprint-id>"
  }
}
```

### Step 3: Create Projects/Milestones/Sprints

Before creating issues, set up organizational structure:

**Linear**:
```typescript
// Create projects for each sprint
const sprint0 = await linear.createProject({
  name: "Sprint 0: Project Setup & Infrastructure",
  description: "Production-ready foundation",
  startDate: "2026-02-07",
  targetDate: "2026-02-14",
  teamId: teamId,
});

const sprint1 = await linear.createProject({
  name: "Sprint 1: Authentication & User Management",
  description: "User signup, login, workspace creation",
  startDate: "2026-02-14",
  targetDate: "2026-02-28",
  teamId: teamId,
});
```

**GitHub**:
```bash
# Create milestones
gh api repos/{owner}/{repo}/milestones \
  -f title="Sprint 0: Project Setup & Infrastructure" \
  -f description="Production-ready foundation" \
  -f due_on="2026-02-14T00:00:00Z"

gh api repos/{owner}/{repo}/milestones \
  -f title="Sprint 1: Authentication & User Management" \
  -f description="User signup, login, workspace creation" \
  -f due_on="2026-02-28T00:00:00Z"
```

**Jira**:
```bash
# Create sprints
curl -X POST https://yourcompany.atlassian.net/rest/agile/1.0/sprint \
  -H "Authorization: Basic $(echo -n email:token | base64)" \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Sprint 0",
    "startDate": "2026-02-07T08:00:00.000Z",
    "endDate": "2026-02-14T17:00:00.000Z",
    "originBoardId": <board-id>
  }'
```

### Step 4: Create Issues/Tasks

For each user story:

**Linear**:
```typescript
const issue = await linear.createIssue({
  teamId: teamId,
  projectId: sprint0.id,
  title: "US-0.1: Developer can deploy to production",
  description: descriptionMarkdown,
  priority: 1, // 0=No priority, 1=Urgent, 2=High, 3=Medium, 4=Low
  estimate: 5, // Story points
  labelIds: [highPriorityLabelId, infrastructureLabelId],
});
```

**GitHub**:
```bash
gh issue create \
  --repo owner/repo \
  --title "US-0.1: Developer can deploy to production" \
  --body "$DESCRIPTION" \
  --label "Sprint 0,Priority: High,Type: Infrastructure" \
  --milestone "Sprint 0"
```

**Jira**:
```bash
curl -X POST https://yourcompany.atlassian.net/rest/api/3/issue \
  -H "Authorization: Basic $(echo -n email:token | base64)" \
  -H "Content-Type: application/json" \
  -d @issue-payload.json
```

### Step 5: Link Related Issues

If blueprint specifies dependencies:

**Linear** (blocking relationships):
```typescript
await linear.createIssueRelation({
  issueId: issue1.id,
  relatedIssueId: issue2.id,
  type: "blocks", // issue1 blocks issue2
});
```

**GitHub** (task lists in description):
```markdown
## Dependencies
- Blocked by #12 (Database setup)
- Blocks #15 (User authentication)
```

**Jira** (issue links):
```json
{
  "type": { "name": "Blocks" },
  "inwardIssue": { "key": "PROJ-1" },
  "outwardIssue": { "key": "PROJ-2" }
}
```

### Step 6: Set Labels/Tags

Create and apply labels:

**Priority Labels**:
- 🔴 Priority: High (Urgent)
- 🟠 Priority: Medium
- 🟢 Priority: Low

**Type Labels**:
- Feature (new functionality)
- Bug (defects)
- Tech Debt (refactoring, infrastructure)
- Documentation

**Sprint Labels**:
- Sprint 0
- Sprint 1
- Sprint 2
- ...

**Component Labels** (from feature areas):
- Authentication
- Database
- Frontend
- Backend
- DevOps
- Security

---

## Output Format

When invoked, generate:

```
🔄 Syncing sprint backlog to Linear...

✅ Detected 8 sprints in blueprint (56 user stories total)
✅ Connected to Linear workspace: Acme Corp
✅ Team: Engineering (team_abc123)

📋 Creating organizational structure...
✅ Created project: Sprint 0 (Feb 7 - Feb 14)
✅ Created project: Sprint 1 (Feb 14 - Feb 28)
✅ Created project: Sprint 2 (Feb 28 - Mar 14)
[... more sprints ...]

🏷️  Creating labels...
✅ Priority: High
✅ Priority: Medium
✅ Priority: Low
✅ Type: Feature
✅ Type: Bug
✅ Type: Tech Debt
✅ Component: Authentication
✅ Component: Database
[... more labels ...]

📝 Creating issues...
✅ US-0.1: Developer can deploy to production (5 pts, High)
✅ US-0.2: Database is provisioned and migrations run (3 pts, High)
✅ US-0.3: Environment variables configured (2 pts, Medium)
[... 53 more issues ...]

🔗 Linking dependencies...
✅ Linked 12 blocking relationships

📊 Summary:
- Sprints: 8
- Total issues: 56
- Story points: 134
- High priority: 18
- Medium priority: 28
- Low priority: 10

🎯 View in Linear:
https://linear.app/acme-corp/project/sprint-0

Next steps:
1. Review issues in Linear
2. Assign team members to issues
3. Start Sprint 0 and begin development
4. Update issue status as work progresses
```

---

## Sync Modes

### 1. One-Time Push (Default)
Create all issues once, no ongoing sync.

**Use when**: Initial project setup, blueprint is final.

```bash
/architect:sync-backlog --platform=linear
```

### 2. Two-Way Sync
Keep blueprint and Linear in sync.

**Use when**: Blueprint evolves, need to track changes.

**Features**:
- Detect new user stories in blueprint → Create issues
- Detect completed issues in Linear → Mark in blueprint
- Detect priority changes → Update both sides

```bash
/architect:sync-backlog --platform=linear --mode=two-way
```

### 3. Export Only (No API)
Generate CSV/JSON for manual import.

**Use when**: No API access, need manual review before import.

```bash
/architect:sync-backlog --platform=csv
# Output: backlog-export.csv
```

---

## Customization Options

**Optional parameters**:

1. **Platform**: linear, github, jira, asana, clickup, csv
2. **Team ID**: Specific team within workspace
3. **Assignees**: Auto-assign to specific users
4. **Start date**: Sprint 0 start date (defaults to today)
5. **Sprint duration**: 1-week, 2-week (default), 3-week, 4-week
6. **Include completed**: Yes/No (sync already-completed sprints)
7. **Dry run**: Preview changes without creating issues

**Examples**:

```bash
# Sync to Linear with 1-week sprints
/architect:sync-backlog --platform=linear --sprint-duration=1-week

# Sync to GitHub with auto-assignment
/architect:sync-backlog --platform=github --repo=owner/repo --assign=@me

# Dry run (preview only)
/architect:sync-backlog --platform=jira --dry-run

# Export to CSV
/architect:sync-backlog --platform=csv --output=backlog.csv
```

---

## Platform-Specific Features

### Linear

**Keyboard Shortcuts Support**:
Add keyboard shortcut hints in issue descriptions:
```markdown
**Quick Actions**:
- `c` - Complete this issue
- `a` - Assign to me
- `l` - Add label
- `p` - Change priority
```

**Cycles Integration**:
Map sprints to Linear cycles automatically:
```bash
/architect:sync-backlog --platform=linear --use-cycles
# Creates or updates cycles for each sprint
```

### GitHub

**GitHub Projects Integration**:
Create a GitHub Project board automatically:
```bash
/architect:sync-backlog --platform=github --create-project
# Creates: "Architecture Implementation" project
# Columns: Backlog, Sprint 0, Sprint 1, ..., In Progress, Done
```

**Issue Templates**:
Generate `.github/ISSUE_TEMPLATE/user-story.md`:
```markdown
---
name: User Story
about: User story from architecture blueprint
labels: user-story
---

**Priority**:

**Story Points**:

**Description**:

**Acceptance Criteria**:
- [ ]
- [ ]

**Technical Notes**:
```

### Jira

**Epics Mapping**:
Create epics for major feature areas:
```
Epic: Authentication System
  ├─ US-1.1: User signup
  ├─ US-1.2: Email verification
  └─ US-1.3: Password reset

Epic: Ticket Management
  ├─ US-2.1: Create ticket
  ├─ US-2.2: Update ticket
  └─ US-2.3: Close ticket
```

**Confluence Integration**:
Generate Confluence page with:
- Architecture overview
- Sprint plan
- Link to blueprint

```bash
/architect:sync-backlog --platform=jira --create-confluence-doc
```

---

## Error Handling

### If API credentials invalid:
- **Action**: Error with link to get credentials
- **Example**: "❌ Linear API key invalid. Get one at https://linear.app/settings/api"

### If sprint already exists:
- **Action**: Prompt user
- **Options**: "1) Skip existing sprints, 2) Update existing issues, 3) Duplicate with new prefix"

### If rate limit hit:
- **Action**: Pause and retry with exponential backoff
- **Notify**: "⏸️  Rate limit hit, pausing 60 seconds..."

### If blueprint section missing:
- **Action**: Error with guidance
- **Example**: "❌ No sprint backlog found. Run `/architect:blueprint` first."

---

## CSV Export Format

For manual import or tools without API:

```csv
Sprint,ID,Title,Description,Priority,Story Points,Acceptance Criteria,Technical Notes,Labels
Sprint 0,US-0.1,Developer can deploy to production,"Set up CI/CD pipeline...",High,5,"- [ ] GitHub Actions workflow configured
- [ ] Deploys on push to main branch","Use GitHub Actions for CI/CD
Vercel for frontend","infrastructure,devops"
Sprint 0,US-0.2,Database is provisioned and migrations run,"Set up PostgreSQL...",High,3,"- [ ] Supabase project created
- [ ] Database connection string in .env","Use Supabase free tier
Prisma for ORM","database,setup"
[...]
```

**Import instructions** included in output:
```
📄 CSV exported to: backlog-export.csv

To import:
- Linear: Import via CSV at linear.app/settings/import
- Jira: Tools → Import → CSV
- GitHub: Use gh-issues-import script
- Asana: Import via CSV at app.asana.com/import
```

---

## Success Criteria

A successful backlog sync should:
- ✅ Create all sprints/milestones/projects
- ✅ Create all user stories as issues/tasks
- ✅ Preserve story points and priorities
- ✅ Include acceptance criteria as checklists
- ✅ Add appropriate labels/tags
- ✅ Link dependencies (blocking relationships)
- ✅ Be immediately actionable (team can start work)
- ✅ Match blueprint structure exactly
- ✅ Provide links to view in target platform
- ✅ Handle errors gracefully (partial sync)

---

## Examples

### Example 1: Linear (Startup)

```bash
/architect:sync-backlog --platform=linear

# Interactive prompts:
# - Linear API key: [paste from linear.app/settings/api]
# - Team: Engineering (auto-detected)
# - Start date: 2026-02-07 (today)
# - Sprint duration: 2 weeks

# Output: 56 issues created across 8 sprints
```

### Example 2: GitHub Issues (Open Source)

```bash
/architect:sync-backlog --platform=github --repo=acme/backend

# Requires: gh CLI authenticated
# Creates: Milestones + Issues + Labels
# Output: Link to project board
```

### Example 3: Jira (Enterprise)

```bash
/architect:sync-backlog --platform=jira

# Interactive prompts:
# - Jira URL: acme.atlassian.net
# - Email: you@acme.com
# - API token: [from id.atlassian.com]
# - Project key: PROJ

# Output: 56 stories created in PROJ project
```

### Example 4: CSV Export

```bash
/architect:sync-backlog --platform=csv --output=backlog.csv

# Output: backlog.csv (ready for manual import)
```
