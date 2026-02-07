---
description: AI agent architecture — orchestration, tools, guardrails, token costs
---

# /architect:agent-spec

## Trigger

`/architect:agent-spec [describe what the agent should do]`

## Purpose

Design a complete AI agent architecture. This is the differentiator command — most architecture tools don't cover AI agents. Produces everything a developer needs to build the agent.

## Workflow

### Step 1: Understand the Agent

If a description is provided, extract:
- What the agent should do (purpose)
- Who interacts with it (user type)
- Where it lives (chat UI, Slack bot, API, etc.)

If not enough context, ask:

> "What should this agent do? Tell me: (1) what task it handles, (2) who uses it, and (3) how they interact with it (chat, Slack, API, etc.)"

### Step 2: Design the Agent

Using the **agent-architecture** skill, determine:
- Best orchestration pattern for this use case
- Required tools
- Optimal LLM provider and model
- Memory strategy
- Guardrails needed

### Step 3: Generate Output

#### Agent Overview

| Field | Value |
|-------|-------|
| **Purpose** | What the agent does (one sentence) |
| **Interface** | How users interact (chat-ui, slack-bot, api, etc.) |
| **Orchestration** | Pattern used (ReAct, multi-agent, etc.) |
| **LLM Provider** | Recommended provider and model |
| **Memory** | Strategy (session, persistent, vector-store) |

#### Why This Architecture

2-3 sentences explaining why this orchestration pattern and LLM were chosen. Use the **founder-communication** skill — explain in plain English, then add technical rationale.

#### LLM Provider Recommendation

| Criteria | Assessment |
|----------|------------|
| Why this provider | Rationale for choosing this LLM |
| Why this model | Rationale for the specific model tier |
| Alternative | Second-best option and when to switch |

#### Tool Definitions

For each tool the agent needs:

```
Tool: [name]
  Type: [agent_tool_type]
  Description: What it does
  Input:
    - [parameter]: [type] — [description]
  Output: What it returns
  Error handling: What happens when it fails
```

#### Memory Strategy

- **Type**: session / persistent / vector-store / hybrid
- **What's stored**: Conversation history, user preferences, knowledge embeddings, etc.
- **Implementation**: Recommended technology (Redis for session, PostgreSQL for persistent, Pinecone for vector)
- **Retention**: How long data is kept

#### Guardrails

Numbered list of explicit guardrails:

1. **[Guardrail name]** — What the agent must/must not do, and what happens when this triggers
2. ...

Include at minimum:
- Identity disclosure rule
- Scope boundary (what the agent refuses to do)
- Escalation triggers (when to hand off to a human)
- Data handling rules (what's never logged or stored)

#### Token Cost Estimate

Using the **agent-architecture** skill token modeling:

| Metric | Estimate |
|--------|----------|
| System prompt tokens | ~X tokens |
| Avg input tokens per turn | ~X tokens |
| Avg output tokens per turn | ~X tokens |
| Avg turns per conversation | X |
| Cost per conversation | ~$X.XX |
| Monthly cost (at Y conversations/mo) | ~$X/mo |

Show the math. Let the user adjust the conversation volume.

#### Agent Flow Diagram

Using the **diagram-patterns** skill, generate a Mermaid agent flow diagram showing:
- User input
- Agent reasoning/routing
- Tool calls
- Guardrail checks
- Output

#### Example Conversation

**Happy path:**
```
User: [typical request]
Agent: [thinks: reasoning] → [calls: tool_name] → [response]
User: [follow-up]
Agent: [response]
```

**Edge case (guardrail trigger):**
```
User: [out-of-scope or risky request]
Agent: [guardrail triggered] → [appropriate response]
```

#### System Prompt Skeleton

A starting system prompt for the agent:

```
You are [agent name], an AI [role] that [purpose].

## What You Do
- [capability 1]
- [capability 2]
- [capability 3]

## What You Don't Do
- [limitation 1]
- [limitation 2]

## Tools Available
- [tool 1]: [when to use it]
- [tool 2]: [when to use it]

## Communication Style
[How the agent should communicate]

## Escalation
[When and how to escalate to a human]
```

## Output Rules

- Use the **agent-architecture** skill for all pattern decisions
- Use the **cost-knowledge** skill for LLM pricing
- Use the **diagram-patterns** skill for the agent flow diagram
- Use the **founder-communication** skill for tone
- Always include token cost estimates with shown math
- Always include guardrails — never design an agent without them
- Always include an example conversation
- Do NOT include the CTA footer
