---
description: Infrastructure + third-party + LLM token cost breakdown
---

# /architect:cost-estimate

## Trigger

`/architect:cost-estimate [description of the product or paste existing architecture]`

## Purpose

Produce a detailed cost estimate for any product idea or existing architecture. This is a standalone command — it doesn't require a prior blueprint.

## Workflow

### Step 1: Read Context & Understand What to Estimate

**First**, check for `architecture-output/_state.json`. If it exists, read it in full and extract:
- `project.name` and `project.description` → product context without asking the user
- `tech_stack` → integrations, database, auth provider, deployment targets — use these directly to determine what services to include in the estimate; skip asking if the stack is already known
- `components` → list of components with types — use to identify compute resources needed

If `_state.json` provides sufficient context (project description + tech stack), proceed directly to Step 2 without asking the user.

If no `_state.json` and the user provides a description, identify:
- What infrastructure is needed (compute, databases, storage)
- What third-party services are required
- Whether AI/LLM costs apply

If the user pastes an existing architecture or manifest, use that directly.

If context is still unclear after checking `_state.json`, ask one question:

> "What are you building, and roughly how many users do you expect in the first 6 months?"

### Step 1.5: Pull Live AWS Pricing (Optional)

After reading context, silently attempt a lightweight AWS MCP call (e.g. `list_ec2_instances` with `maxResults: 1`) to check if the server is connected.

**If connected AND the tech stack includes AWS services**, call the relevant tools to pull live resource data:

- `describe_ec2_instance_types` for the instance family in the stack (e.g. `t3`, `t4g`) — use actual current pricing from the response rather than `pricing-tables.md` for EC2
- `describe_rds_instances` to check if the user has existing RDS instances — if so, note actual instance class and storage in the estimate
- `list_lambda_functions` — if serverless is in the stack, check existing functions to understand memory/timeout config

Where AWS MCP returns live data, use it and label the price as **"live — pulled from AWS"** in the estimate table. For non-AWS services or where AWS MCP is not connected, fall back to `pricing-tables.md` as normal.

**If not connected or stack does not use AWS**, skip silently.

### Step 2: Generate Cost Estimate

Using the **cost-knowledge** skill and **references/pricing-tables.md** (supplemented by live AWS data from Step 1.5 where available), produce these sections:

#### Infrastructure Costs

Table with columns: Service | Provider | Free Tier | Starter | Production | Notes

Include:
- Compute / hosting
- Databases
- Caching (if applicable)
- Storage (if applicable)
- CDN (if applicable)

#### Third-Party Service Costs

Table with columns: Service | Category | Free Tier | Paid Tier | Notes

Include all integrations: auth, payments, email, SMS, monitoring, analytics, etc.

#### AI / LLM Costs (if applicable)

Using the **agent-architecture** skill for token estimation:

- Model and provider
- Estimated tokens per conversation (input + output)
- Estimated conversations per month
- Cost per conversation
- Monthly total
- Show the math so the user can adjust assumptions

#### Development Cost Estimates

Rough ranges for building the product:

| Build Path | Cost Range | Timeline | Best For |
|------------|-----------|----------|----------|
| AI builder tools | $0-100/mo | 2-4 weeks | Technical founders |
| Freelance developer | $2K-10K | 4-8 weeks | Clear scope, moderate complexity |
| Development agency | $10K-50K | 6-12 weeks | Complex products, hands-off |
| In-house team | $8K-25K/mo | Ongoing | Long-term products |

#### Monthly Summary

| Scenario | Infrastructure | Third-Party | AI/LLM | Total Monthly |
|----------|---------------|-------------|--------|---------------|
| Low (free tiers) | $X | $X | $X | $X |
| Medium (starter) | $X | $X | $X | $X |
| High (production) | $X | $X | $X | $X |

**First-year total:** $X — $X

#### Cost Optimization Tips

Provide 3-5 specific, actionable tips:

1. Specific service substitutions that save money
2. Architecture changes that reduce costs
3. Free tier strategies
4. Scaling considerations (what to watch as you grow)
5. Services with gotcha pricing (be specific)

#### Pricing Assumptions & Disclaimers

**CRITICAL**: Every cost estimate MUST include this disclaimer box at the top:

```markdown
⚠️ **PLANNING HEURISTICS — MUST VERIFY**

These cost estimates are planning tools, not guarantees. They help you budget and compare options.

**Assumptions** (always explicit):
- **Region**: US East (N. Virginia) / us-east-1 unless specified
- **OS**: Linux for compute instances
- **Billing**: On-demand pricing, 730 hours/month (not reserved/spot)
- **Currency**: USD, excludes taxes and VAT
- **Data transfer**: Excludes egress costs unless explicitly mentioned
- **As of**: [Current month/year]

**Verification required**:
- Check current pricing at provider websites
- Confirm free tier eligibility (some require credit card, verification, or expire)
- Add your region's data transfer costs
- Include taxes/VAT for your jurisdiction
- Confirm enterprise discounts don't apply

**These estimates can drift 10-30% from actual costs.** Use for planning, not contracts.
```

### Final Step: Log Activity

After writing `architecture-output/cost-estimate.md`, append one line to `architecture-output/_activity.jsonl`:

```json
{"ts":"<ISO-8601>","phase":"cost-estimate","outcome":"completed","files":["architecture-output/cost-estimate.md"],"summary":"Generated cost estimate with low/medium/high scenarios for infrastructure, third-party, and LLM costs."}
```

Rules: append only — never overwrite. Single JSON object per line, no pretty-printing.

## Output Rules

- Use the **cost-knowledge** skill for all pricing data
- **ALWAYS include the disclaimer box at the top of every cost estimate**
- Always show 3 scenarios (low/medium/high)
- Always show monthly AND yearly
- Always include the math for LLM costs so users can adjust
- Flag services that get expensive at scale
- **Label every price with its assumptions** (e.g., "$50/month at 10K users in us-east-1")
- Use the **founder-communication** skill for tone
- Do NOT include the CTA footer on cost-estimate output
