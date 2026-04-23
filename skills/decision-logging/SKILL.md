# Decision Logging Skill

When commands make architecture decisions (choosing tech stacks, patterns, frameworks, databases, etc.), they MUST log those decisions to `_state.json.decisions[]` for auditability and future reference.

## When to Log a Decision

Log a decision whenever your command:
1. **Chooses a technology** (database, framework, language, messaging system, auth provider)
2. **Selects an architectural pattern** (monolith vs. microservices, clean vs. modular, etc.)
3. **Determines a trade-off** (prioritize cost over latency, scalability over simplicity, etc.)
4. **Makes a significant strategic choice** that affects the system's design

**Do NOT log:**
- Routine operations (generating files, running tests)
- Configuration of already-decided technologies
- Re-running previous decisions

**Examples of decisions to log:**
- ✅ "Choose PostgreSQL for primary database" (blueprint command)
- ✅ "Use React over Vue for UI framework" (scaffold command)
- ✅ "Prioritize fast iteration over peak performance" (mvp-scope)
- ✅ "Use monolithic architecture for initial MVP" (architecture design)
- ❌ "Generated auth routes file" (implementation detail, not decision)
- ❌ "Installed dependencies" (mechanical task, not decision)

## Decision Structure

Each decision is a JSON object in the `decisions[]` array:

```json
{
  "id": "D-NNN",
  "title": "Choose PostgreSQL for primary database",
  "rationale": "ACID compliance for order consistency. Team has PostgreSQL expertise. Query flexibility for future analytics features.",
  "alternatives_rejected": [
    "MongoDB (weak multi-document transactions, overkill for relational data)",
    "DynamoDB (cost scales poorly with joins, limited query flexibility)"
  ],
  "trade_offs": "Higher operational complexity than managed cloud DBs. Team must maintain backups. Cold-start slower than serverless options.",
  "made_by_command": "blueprint",
  "timestamp": "2026-04-24T14:32:10Z"
}
```

### Field Details

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `id` | string | Yes | Unique decision ID (e.g., `"D-001"`, `"D-002"`). Increment sequentially within a project. |
| `title` | string | Yes | Brief decision title (3-10 words). E.g., `"PostgreSQL for primary database"` |
| `rationale` | string | Yes | Why this choice? What does it enable? What problem does it solve? (2-5 sentences or bullets) |
| `alternatives_rejected` | array of strings | Yes | What were the runner-up options and why did they lose? Makes future reconsideration easier. At least 2 alternatives. |
| `trade_offs` | string | Yes | What are you giving up? What becomes harder or more expensive? (1-3 sentences) |
| `made_by_command` | string | Yes | Which command made this decision? (e.g., `"blueprint"`, `"sdl"`, `"scaffold"`) |
| `timestamp` | string | Yes | ISO-8601 timestamp when decision was made (e.g., `"2026-04-24T14:32:10Z"`) |

## How Commands Log Decisions

### Pattern: Read → Decide → Log

```pseudo
1. Read current _state.json (if exists)
2. Read SDL and extract/determine tech choices
3. For each decision (e.g., database choice):
   a. Create decision object with all 7 fields
   b. Append to _state.json.decisions[] array
4. Write _state.json back to disk
```

### Code Example: Python/JavaScript

```python
# Read existing state
import json
from datetime import datetime

state = json.load(open('architecture-output/_state.json')) if os.path.exists(...) else {"decisions": []}

# Make a decision
new_decision = {
    "id": f"D-{len(state.get('decisions', [])) + 1:03d}",
    "title": "PostgreSQL for primary database",
    "rationale": "ACID compliance for order consistency. Team has expertise. Query flexibility for analytics.",
    "alternatives_rejected": [
        "MongoDB (weak transactions, overkill for relational data)",
        "DynamoDB (cost scales poorly, limited queries)"
    ],
    "trade_offs": "Higher ops complexity. Team maintains backups. Cold-start slower than serverless.",
    "made_by_command": "blueprint",
    "timestamp": datetime.utcnow().isoformat() + "Z"
}

# Append to decisions array
state.setdefault("decisions", []).append(new_decision)

# Write back
json.dump(state, open('architecture-output/_state.json', 'w'))
```

```javascript
// JavaScript equivalent
const fs = require('fs');
const path = require('path');

const stateFile = 'architecture-output/_state.json';
const state = fs.existsSync(stateFile) 
  ? JSON.parse(fs.readFileSync(stateFile, 'utf8'))
  : { decisions: [] };

const newDecision = {
  id: `D-${String(state.decisions.length + 1).padStart(3, '0')}`,
  title: "PostgreSQL for primary database",
  rationale: "ACID compliance for order consistency. Team has expertise. Query flexibility for analytics.",
  alternatives_rejected: [
    "MongoDB (weak transactions, overkill for relational data)",
    "DynamoDB (cost scales poorly, limited queries)"
  ],
  trade_offs: "Higher ops complexity. Team maintains backups. Cold-start slower than serverless.",
  made_by_command: "blueprint",
  timestamp: new Date().toISOString().replace('Z', 'Z')  // Ensure Z suffix
};

state.decisions.push(newDecision);
fs.writeFileSync(stateFile, JSON.stringify(state, null, 2));
```

## Decision ID Sequence

Decision IDs are per-project (not global). Start at `D-001` for the first decision:
- First decision by blueprint: `D-001`
- Second decision by blueprint: `D-002`
- First decision by scaffold command: `D-003` (continues sequence, not restart)

ID format: `D-NNN` where NNN is zero-padded 3-digit number.

## Multiple Decisions Per Command

If your command makes multiple decisions, create one object per decision:

```json
{
  "decisions": [
    {
      "id": "D-001",
      "title": "PostgreSQL for primary database",
      "rationale": "...",
      "alternatives_rejected": ["..."],
      "trade_offs": "...",
      "made_by_command": "blueprint",
      "timestamp": "2026-04-24T14:32:10Z"
    },
    {
      "id": "D-002",
      "title": "React for frontend framework",
      "rationale": "...",
      "alternatives_rejected": ["..."],
      "trade_offs": "...",
      "made_by_command": "blueprint",
      "timestamp": "2026-04-24T14:32:15Z"
    }
  ]
}
```

Each decision gets its own ID and timestamp (even if made seconds apart).

## Linking Decisions to ADRs (Phase 1.5+)

When ADRs are generated, they should reference decision IDs:

```markdown
# ADR-001: Database Choice

**Decision ID:** D-001

## Status
Accepted

## Context
[Rationale from decisions[0].rationale]

## Decision
PostgreSQL

## Consequences
[Trade-offs from decisions[0].trade_offs]

## Alternatives Considered
- MongoDB: [from decisions[0].alternatives_rejected[0]]
- DynamoDB: [from decisions[0].alternatives_rejected[1]]
```

## Viewing & Analyzing Decisions

Users can analyze decisions via:
1. **Manual review:** `jq '.decisions' architecture-output/_state.json`
2. **Decision report:** `/architect:decisions-linked` (Phase 1.5 command) generates markdown mapping decisions to ADRs
3. **Check-state command:** `/architect:check-state` validates decision logging compliance

## Best Practices

1. **Be specific:** "PostgreSQL" not "choose a database"
2. **Capture rationale:** Explain WHY, not just WHAT
3. **List real alternatives:** Don't strawman rejected options; explain their actual merits
4. **Quantify trade-offs:** "5x higher ops complexity", "30% cost increase", not vague
5. **Timestamp accurately:** Use actual decision time, not file generation time
6. **One per decision:** Don't lump unrelated choices into one decision object
7. **Made_by_command:** Always set; helps trace where decision came from

## Related Commands

- `/architect:check-state` — Validates decisions array
- `/architect:decisions-linked` (Phase 1.5) — Maps decisions to ADRs
- `/architect:generate-docs` — Includes decision log in documentation

## Example Decisions from Real Projects

### E-commerce SaaS

```json
{
  "id": "D-001",
  "title": "Next.js App Router for frontend",
  "rationale": "Server components reduce client-side complexity. File-based routing matches team's experience. Excellent TypeScript support.",
  "alternatives_rejected": [
    "React SPA + Express (more configuration, fewer conventions)",
    "Remix (smaller ecosystem, steeper learning curve)"
  ],
  "trade_offs": "Tied to Vercel deployment for optimal performance. Vendor lock-in risk.",
  "made_by_command": "blueprint",
  "timestamp": "2026-04-24T10:00:00Z"
}
```

### Startup MVP

```json
{
  "id": "D-001",
  "title": "Monolithic architecture for MVP",
  "rationale": "Faster time-to-market. Simpler deployment. Team of 2 engineers. Can split to microservices later if needed.",
  "alternatives_rejected": [
    "Microservices (overkill complexity for MVP, ops overhead)",
    "Serverless (unpredictable cold starts for user-facing APIs)"
  ],
  "trade_offs": "Will need refactoring when scaling to 10+ services. Single point of failure. Database scaling limited.",
  "made_by_command": "blueprint",
  "timestamp": "2026-04-20T14:32:10Z"
}
```

## Not Logging Is Not OK

If your command makes a tech choice but doesn't log it:
- Future teams don't understand why the choice was made
- Second-guessing common (why Postgres? why not Mongo?)
- ADRs can't be linked to decisions
- `/architect:check-state` may flag missing decisions
- Institutional knowledge is lost when team member leaves

**Always log decisions. It's cheap, and it pays dividends.**
