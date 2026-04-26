---
description: Synthesize all ideation research into a single, actionable briefing with go/no-go recommendation
---

# /architect:ideation-briefing

## Trigger

`/architect:ideation-briefing` — Run **after** completing `/architect:deep-research`, `/architect:user-personas`, `/architect:problem-validation`, and `/architect:mvp-scope`.

## Purpose

Synthesize all ideation research outputs into ONE actionable briefing document that answers the founder's real question: "Should we build this? How do we win? What's the realistic timeline?"

Eliminates the need to read 4+ separate documents and manually connect the dots. Founders get:
- Executive summary (1 page) with clear recommendation
- Detailed analysis (5-6 pages) showing cross-cutting insights
- Risk summary with mitigations
- 90-day action plan

## Workflow

### Step 1: Load Tier 1 Outputs

Read in this order (stop if any file is missing and ask user to run prerequisite command):

```
Read: architecture-output/_state.json (compact summaries from all tier 1 commands)
Read: architecture-output/deep-research.md (market, competitors, parity, momentum)
Read: architecture-output/user-personas.md (personas, prioritization, validation)
Read: architecture-output/problem-validation.md (problem score, assumptions, experiments)
Read: architecture-output/mvp-scope.md (features, timeline, bottlenecks, gates)
```

**Prerequisite check**: If any file is missing, stop and ask:
> "I need [file] to create the briefing. Run `/architect:[command]` first, then come back here."

### Step 2: Load Skills

Load:
- **founder-communication** skill — write for founders/investors, not engineers
- **deep-research** skill — use for confidence tagging when synthesizing data

### Step 3: Competitive Position Analysis

Cross-analyze deep-research and mvp-scope outputs:

```markdown
## Competitive Position

**Feature Parity Score**: [X%] (from deep-research)
- We match [X% of] competitor features
- Assessment: [ahead/parity/behind]
- Gap strategy: [what closes the gap?]

**Competitive Momentum vs Us**:
| Competitor | Momentum Score | Timeline | Our Advantage |
|---|---|---|---|
| [CompA] | [X/100] | [accelerating/stalled] | [our angle] |

**Positioning**: 
- Competitors positioned on: [2x2 axes from deep-research]
- Our positioning: [white space we occupy]
- Why we win: [based on MVP scope + persona needs + momentum gap]

**Risk**: [CompA just raised $X, implications for us]
```

### Step 4: Market Entry Strategy

Cross-analyze deep-research market sizing + personas + problem-validation:

```markdown
## Market Entry Strategy

**TAM/SAM/SOM**:
- TAM: [X] (confidence: [High/Med/Low])
- SAM: [Y] (derived from target segment)
- SOM: [Z] (realistic 3-year capture)

**Target Segment Analysis**:
- Primary: [segment name] — [size], [growth rate]
- Why we start here: [why this segment first]
- Secondary: [segment name] — [size], [why deferred]

**Persona-Market Alignment**:
| Persona | Segment | Validated | Size | Willingness-to-Pay |
|---|---|---|---|---|
| [P1] | [Segment] | ✅ | [S/M/L] | $[X-Y]/mo |
| [P2] | [Segment] | ⚠️ | [S/M/L] | $[X-Y]/mo |

**Persona gaps found**: [if validation revealed misalignments, describe and recommend action]
```

### Step 5: Problem Validation Scorecard

Extract from problem-validation outputs:

```markdown
## Problem Validation

**Problem Score**: [X/100] (from frequency + severity analysis)

| Problem | Frequency | Severity | Validation | Confidence |
|---|---|---|---|---|
| [Primary] | [X%] | [High] | [Score] | [High/Med] |
| [Secondary] | [X%] | [Medium] | [Score] | [Med] |

**Kill-switch assumptions** (P0 — test first):
- [Assumption 1] — Confidence: [H/M/L]
- [Assumption 2] — Confidence: [H/M/L]

**Why this problem matters for MVP**:
[Most critical problem that MVP MUST solve to prove concept]
```

### Step 6: MVP Differentiation Assessment

Cross-analyze mvp-scope features against competitor parity + momentum:

```markdown
## MVP Differentiation

**Does our MVP stand out?**

|  vs CompA | vs CompB | vs CompC | Our Angle |
|---|---|---|---|
| [Feature comparison] | [Feature comparison] | [Feature comparison] | [What we do better] |

**Positioning**:
- CompA is [expensive + complex] → We compete on [simplicity + price]
- CompB is [cheap + limited] → We compete on [features + UX]
- CompC is [premium + easy] → We compete on [affordability + performance]

**Differentiation Confidence**: [High/Med/Low]
- High: Clear gap, underserved segment wants it
- Medium: Good angle but CompX could copy in 3-6 months
- Low: Weak differentiation, relying on speed to market

**Risk**: [If differentiation is weak, what's the backup plan?]
```

### Step 7: Timeline Realism Check

Cross-analyze mvp-scope estimates against team capacity + bottlenecks:

```markdown
## Timeline & Execution Reality

**Original Estimate**: [X weeks]
**Adjusted Estimate**: [Y weeks] (includes overrun buffer + bottleneck mitigation)

**Critical Path**:
- Phase 1 (Foundation): [Z days] — Backend engineer 100% allocated
- Phase 2 (Core Loop): [Z days] — Backend bottleneck begins
- Phase 3 (Complete): [Z days] — Need contractor or feature deferral
- Phase 4 (Polish): [Z days]

**Resource Bottleneck**:
- Constraint: [Backend engineer doing auth + API + data import]
- Cost of not hiring: +[X days] to timeline
- Recommendation: [Hire contractor / Defer feature / Accept delay]

**Historical accuracy check**:
- Similar projects overran by: [X%]
- Adjusted timeline: [Y weeks with buffer]
- Risk if we slip 2 weeks: [MVP ships on [date]]
```

### Step 8: Recommendation & Risk Summary

```markdown
## Go / No-Go Recommendation

**Status**: [GO / GO WITH CONDITIONS / NEEDS MORE VALIDATION / NO-GO]

**Confidence**: [65% / 75% / 85%+]

**Why [GO / NO-GO]**:
- ✅ [Supporting finding 1]
- ✅ [Supporting finding 2]
- ⚠️ [Risk 1 — but mitigable by...]
- 🔴 [Risk 2 — significant concern]

**Top 3 Risks & Mitigations**:
| Risk | Level | Mitigation | Owner | Timeline |
|---|---|---|---|---|
| [Risk 1] | Medium | [Action] | [Owner] | [When] |
| [Risk 2] | High | [Action] | [Owner] | [When] |
| [Risk 3] | Medium | [Action] | [Owner] | [When] |

**Kill-switch risks** (would kill the company):
- [If X assumption is false, we fail]
- [Mitigation: Validate via experiment Y in week Z]

**Biggest Assumption**: [The one thing most likely to be wrong]
- **Test**: [How to validate it cheaply]
- **Timeline**: [When to know if it's true]
- **Cost if wrong**: [What happens if it's false]
```

### Step 9: Experiment Roadmap

Cross-reference problem-validation experiment sequencing with timeline:

```markdown
## 90-Day Validation & Build Plan

**Week 1-2**: Smoke Test (validate problem exists)
- Assumption tested: Market size + demand
- Success criteria: [X% signup rate]
- Blocker if fails: Stop, pivot

**Week 2-4**: Customer Discovery + Technical Spike (parallel)
- Interviews: Validate pain + WTP
- Prototype: Validate core buildability
- Blocker if fails: Reevaluate scope or segment

**Week 4-8**: MVP Build (with weekly gates)
- Week 4: Auth + DB complete
- Week 6: Core loop functional (internal users only)
- Week 8: Beta ready (quality gates passed)

**Week 8-12**: Beta Launch + Iteration
- External users: 5-10 beta testers
- Success metric: Core action completion rate >60%
- Decision: Ship or iterate

**Gate**: Product-market fit threshold
- [X% of beta users say they'd pay for this]
- [X% complete core action daily]
- If met: Proceed to Series A / Full build
- If not: Iterate or pivot
```

### Step 10: Write Output

Write to: `architecture-output/ideation-briefing.md`

**Structure** (match founder-communication style):

1. **Executive Summary** (1 page, 300-400 words)
   - What we're building (1 sentence)
   - Market opportunity (TAM + segment)
   - Why we win (competitive advantage)
   - Go/no-go recommendation + confidence
   - One critical action to take next

2. **Detailed Analysis** (5-6 pages)
   - Sections 3-9 from workflow above
   - Use tables for structured data
   - Use Mermaid diagrams for timelines, dependencies
   - Lead with insights, not data

3. **Risk & Mitigation** (1-2 pages)
   - Top 5 risks with specific mitigations
   - Kill-switch assumptions
   - Decision gates (go/hold/pivot triggers)

4. **Appendix: Cross-References**
   - See deep-research.md for [X]
   - See user-personas.md for [Y]
   - See problem-validation.md for [Z]
   - See mvp-scope.md for [timeline details]

### Step 11: Update _state.json

After writing `ideation-briefing.md`, update `architecture-output/_state.json`:

```json
{
  "ideation_briefing": {
    "generated_at": "<ISO-8601>",
    "recommendation": "go|go_conditional|needs_validation|no_go",
    "confidence": 75,
    "timeline_realistic_weeks": 10,
    "biggest_risk": "[risk name]",
    "kill_switch_assumptions": ["assumption 1", "assumption 2"],
    "next_step": "[One specific action to take next week]",
    "critical_dates": {
      "smoke_test_complete": "YYYY-MM-DD",
      "customer_discovery_complete": "YYYY-MM-DD",
      "mvp_launch": "YYYY-MM-DD",
      "pog_gate": "YYYY-MM-DD"
    }
  }
}
```

### Step 12: Log Activity

Append to `architecture-output/_activity.jsonl`:

```json
{"ts":"<ISO-8601>","phase":"ideation-briefing","outcome":"completed","files":["architecture-output/ideation-briefing.md"],"summary":"Synthesized all ideation research. Recommendation: [status]. Confidence: [X]%. Next step: [action]."}
```

### Signal Completion

Emit marker:

```
[IDEATION_BRIEFING_DONE]
```

## Output Rules

- Write for a founder who needs to make a decision, not for a researcher who loves detail
- Every number should have a confidence tag ([Verified], [Estimated], [Inferred])
- Every claim should be traceable back to a Tier 1 output
- Keep the first page (executive summary) truly one page — founder should be able to read it in 5 minutes
- Use tables for comparisons, not prose
- Use Mermaid diagrams for timelines
- Do NOT include sections just because they're standard — only include if it matters for the decision
- Do NOT ask questions — make a clear recommendation

## When to Use Ideation-Briefing

**Always** — Run this after completing all four Tier 1 commands. It's the synthesis point that founders read.

**Never** — Don't run this standalone. It requires all four Tier 1 outputs as input.

## What Founders Learn

After reading this brief (30 min), they should be able to:
- ✅ State the recommendation (go/no-go) and why
- ✅ Identify the 3 biggest risks and mitigations
- ✅ Know the realistic timeline (not optimistic estimate)
- ✅ Know which assumptions to test first
- ✅ Make a go/no-go decision with confidence
