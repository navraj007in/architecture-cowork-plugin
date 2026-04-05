---
description: Analyze project for compliance gaps across SOC2, HIPAA, GDPR, and PCI DSS frameworks
---

# /architect:compliance

## Trigger

`/architect:compliance [options]`

Options:
- `[frameworks:sox2,hipaa,gdpr,pci]` — specify which to audit (comma-separated; default: all applicable)
- `[non_interactive:true]` — skip all questions, derive from SDL

## Purpose

Production systems need to comply with regulatory frameworks. This command scans your project for compliance gaps, produces a prioritized remediation plan, and documents the current control state. Covers SOC2 Type II, HIPAA, GDPR, and PCI DSS — mapping each framework's controls to code-level implementation patterns.

## Workflow

## Quick Navigation

| Phase | Steps |
|-------|-------|
| **Setup** | [Step 1](#step-1-read-context-and-detect-frameworks) · [Step 1.5](#step-15-determine-applicable-frameworks) |
| **Analysis** | [Step 2](#step-2-ask-configuration-questions) · [Step 2.5](#step-25-read-compliance-skill) |
| **Scanning** | [Step 3](#step-3-delegate-to-compliance-scanner-agent) · [Step 3.5](#step-35-verify-scan-results) |
| **Completion** | [Step 4](#step-4-log-activity) · [Step 4.5](#step-45-update-_statejson) · [Step 5](#step-5-signal-completion) |

### Step 1: Read Context and Detect Frameworks

ℹ️ **CONTEXT LOADING:** _state.json → SDL → project structure

**First**, read `architecture-output/_state.json` if it exists. Extract:
- `project.name`, `project.stage`
- `tech_stack.backend`, `tech_stack.database` (determines scope)
- Any existing `compliance` section (if this is a re-audit)

**Then**, read SDL to detect compliance flags:
- `nonFunctional.security.compliance[]` — list of applicable frameworks (SOC2, HIPAA, GDPR, PCI)
- `nonFunctional.security.pii` — does system handle Personally Identifiable Information?
- `nonFunctional.security.phi` — does system handle Protected Health Information (healthcare)?
- `nonFunctional.security.pci` — does system handle payment card data?

**Check project structure:**
- Look for existing compliance artifacts: `docs/compliance/`, `docs/security/`, audit reports
- Check for encryption implementations: `src/lib/encryption.ts`, `.env` with encryption keys
- Look for audit logging: `src/lib/logger.ts`, `src/lib/auditLog.ts`

### Step 1.5: Determine Applicable Frameworks

❓ **DECISION POINT:** Framework applicability detection

Based on SDL + project structure, determine which frameworks MUST be audited:

| Flag | Framework | Requirement |
|------|-----------|-------------|
| `compliance.includes('SOC2')` | SOC2 Type II | Explicitly declared |
| `pii: true` | GDPR | Always applicable if handling EU user data |
| `phi: true` | HIPAA | Always applicable if handling healthcare data |
| `pci: true` | PCI DSS | Always applicable if handling payment cards |

If frameworks are not declared in SDL:
- Default SOC2 for all SaaS products (security best practice)
- Ask user to confirm which apply

### Step 2: Ask Configuration Questions

❓ **DECISION POINT:** User-specified frameworks and audit scope

**If not in non-interactive mode**, ask:

1. **Which frameworks to audit?**
   > "Which compliance frameworks apply to your project?"
   > - SOC2 Type II (SaaS, security best practice)
   > - HIPAA (healthcare, if handling PHI)
   > - GDPR (if serving EU users or handling personal data)
   > - PCI DSS (if accepting payments or storing card data)
   > - All that apply

2. **Data sensitivity scope** (if not obvious from SDL):
   > "What's the highest sensitivity data you handle?"
   > - Public data (no compliance needed)
   > - Internal data (SOC2 only)
   > - Personal/PII data (SOC2 + GDPR)
   > - Healthcare/PHI (SOC2 + HIPAA)
   > - Payment card data (SOC2 + PCI DSS)

3. **Timeline for audit** (if frameworks declared):
   > "When do you need to be audit-ready?"
   > - Already in audit (critical path)
   > - Next 3 months (plan remediation soon)
   > - Next 6 months (can prioritize)
   > - Planning/informational (lower priority)

**If `[non_interactive:true]`**, derive:
- Frameworks from SDL `nonFunctional.security.compliance[]`
- Sensitivity from `pii`, `phi`, `pci` flags
- Timeline defaults to "Next 6 months"

### Step 2.5: Read Compliance Skill

🔄 **SKILL LOAD:** Read skills/compliance/SKILL.md

Before delegating, read `skills/compliance/SKILL.md` in full. This skill is the authoritative guide for:
- SOC2 Type II controls (CC, A, C, I categories)
- HIPAA technical safeguards (access, audit, encryption)
- GDPR data rights implementation (access, erasure, portability)
- PCI DSS scope reduction and safe card handling
- Audit logging patterns and evidence collection
- Compliance scoring matrix (critical, high, medium, low gaps)

The compliance-scanner agent will reference this skill for all gap analysis.

### Step 3: Delegate to compliance-scanner Agent

🔄 **AGENT DELEGATION:** Launch compliance-scanner agent (autonomous, gap-analyzing)

Pass the following to the **compliance-scanner** agent:

- **Frameworks to audit** (from Step 2):
  - frameworks: [SOC2, HIPAA, GDPR, PCI] (subset based on user selection)

- **Project context**:
  - `_state.json.project.stage` — MVP/growth/enterprise (affects control expectations)
  - `_state.json.tech_stack` — languages, databases, cloud provider
  - SDL `nonFunctional.security` section
  - Scaffolded component list with paths

- **Data sensitivity** (from Step 2):
  - handles_pii: true/false
  - handles_phi: true/false
  - handles_payment_data: true/false

- **Reference materials**:
  - Path to `skills/compliance/SKILL.md` — agent will read and follow
  - Path to scaffolded codebase for scanning

**The agent MUST:**
1. Scan source code for compliance gaps (file-by-file analysis)
2. Assess each framework's controls: implemented / partial / missing / not applicable
3. Generate gap report per framework with:
   - Control name + requirement
   - Current state (code evidence)
   - Gap description (what's missing)
   - Remediation step (code to add)
   - Effort estimate (hours)
4. Create `architecture-output/compliance/` with:
   - `compliance-index.md` — overview and quick navigation
   - `compliance-soc2.md` — SOC2 controls + gaps (if applicable)
   - `compliance-hipaa.md` — HIPAA safeguards + gaps (if applicable)
   - `compliance-gdpr.md` — GDPR articles + gaps (if applicable)
   - `compliance-pci.md` — PCI DSS scope + gaps (if applicable)
5. Create `compliance-remediation.md` — prioritized fix list (critical → high → medium → low)
6. Create `compliance-audit-checklist.md` — evidence collection guide for auditors

**The agent MUST NOT:**
- Modify any source code (only analyze and report)
- Guarantee compliance (that's a legal determination)
- Skip frameworks declared in SDL
- Over-scope to unrelated security concerns (focus on compliance only)

### Step 3.5: Verify Scan Results

✅ **QUALITY GATE:** Check generated files before proceeding

After the agent completes, verify the compliance reports:

For each framework:
1. Check that `compliance-{framework}.md` exists
2. Check that gap count > 0 (at minimum, need to document controls assessed)
3. Check that each gap includes: control name, current state, remediation step, effort
4. Check that `compliance-remediation.md` prioritizes gaps (critical first)
5. Check that `compliance-audit-checklist.md` lists evidence needed per control

If verification fails:
- Report missing files to the user
- Do NOT block completion — user can request re-scan or manual review
- Continue to Step 4

### Step 4: Log Activity

Append one line to `architecture-output/_activity.jsonl`:

```json
{"ts":"<ISO-8601>","phase":"compliance","outcome":"completed","frameworks":["SOC2","GDPR"],"gap_count":12,"critical_gaps":2,"high_gaps":5,"files_generated":6,"summary":"Compliance audit complete: SOC2 + GDPR. 2 critical gaps (encryption, audit logging), 5 high gaps (GDPR rights), 5 medium gaps. Remediation plan in compliance-remediation.md."}
```

For each framework audited, also append to `architecture-output/compliance/_activity.jsonl` (create if needed):

```json
{"ts":"<ISO-8601>","framework":"SOC2","status":"scanned","controls_total":22,"controls_implemented":18,"controls_partial":2,"controls_missing":2,"summary":"SOC2 Type II: 18/22 controls implemented. Gaps: CC6.4 (backup testing), CC7.4 (key management)."}
```

### Step 4.5: Update _state.json

Read existing `architecture-output/_state.json` (or start with `{}`).

Merge ONLY the `compliance` field:

```json
{
  "compliance": {
    "generated_at": "<ISO-8601>",
    "frameworks": ["SOC2", "GDPR"],
    "gap_count": 12,
    "critical_gaps": 2,
    "high_gaps": 5,
    "medium_gaps": 4,
    "low_gaps": 1,
    "controls_by_framework": {
      "SOC2": {
        "total": 22,
        "implemented": 18,
        "partial": 2,
        "missing": 2
      },
      "GDPR": {
        "total": 7,
        "implemented": 5,
        "partial": 1,
        "missing": 1
      }
    },
    "remediation_effort_hours": 48,
    "files_generated": 6
  }
}
```

Write back to `architecture-output/_state.json` without overwriting other fields.

### Step 5: Signal Completion

🚀 **COMPLETION MARKER:** Emit [COMPLIANCE_DONE]

Emit the completion marker:

```
[COMPLIANCE_DONE]
```

This ensures the compliance audit phase is marked as complete in the project state.

## Error Handling

### Missing SDL or Security Flags

If SDL is missing or `nonFunctional.security` is not defined:
> "I need an SDL with security configuration to audit compliance. Run `/architect:blueprint` first, then come back here."

### No Frameworks Applicable

If user answers "none" to all framework questions:
- Report: "No compliance frameworks selected. For SaaS products, SOC2 is recommended best practice."
- Offer to audit SOC2 as baseline

### Source Code Not Readable

If source code cannot be scanned (syntax errors, large files, unsupported languages):
- Log warning: `"code_scan_failed_<file>"`
- Report: "Some files could not be analyzed. Manual review recommended for [component]."
- Continue with other components

### Remediation Effort Too High

If total remediation effort exceeds 200 hours:
- Report: "Total remediation effort is [X] hours. Recommend phased approach:"
  - Phase 1 (critical, < 40 hours)
  - Phase 2 (high, < 80 hours)
  - Phase 3 (medium/low, remaining)

### Unable to Write Compliance Reports

If `architecture-output/compliance/` cannot be created due to permissions:
- Stop execution
- Report: "Cannot create compliance directory: [error]. Check file permissions."
- Do NOT emit completion marker

## Output Rules

- Use the **founder-communication** skill for tone (technical but accessible to non-engineers)
- Generated reports MUST follow the compliance-skill exactly (control mappings, code patterns)
- Do NOT provide legal advice — only technical implementation guidance
- Do NOT guarantee compliance (determination is legal + auditor's decision)
- Always frame gaps as improvement opportunities, not failures
- Include remediation code samples for every gap
- Prioritize critical gaps (no encryption, no audit logging) before others
- Document current control state with code evidence (GitHub links, config files)
- Provide effort estimates per remediation
- Do NOT include the CTA footer
