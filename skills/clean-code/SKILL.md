---
name: clean-code
description: Structural code quality rules applied at write time (implementer, scaffolder) and check time (reviewer). Covers function length, single responsibility, abstraction levels, meaningful naming, magic values, parameter design, boolean traps, DRY, dead code, premature abstraction, and frontend component decomposition.
---

# Clean Code Skill

Structural quality rules for writing and reviewing code within the Archon plugin. These rules are cross-runtime principles with runtime-specific thresholds captured in tables within each sub-file.

## What this skill covers

| Rule ID | Name | Sub-file |
|---------|------|---------|
| CC-S1 | Function length | `structure.md` |
| CC-S2 | Single responsibility | `structure.md` |
| CC-S3 | Abstraction levels | `structure.md` |
| CC-N1 | Meaningful names | `naming.md` |
| CC-N2 | Magic values | `naming.md` |
| CC-I1 | Parameter count | `interface.md` |
| CC-I2 | Boolean trap | `interface.md` |
| CC-H1 | DRY | `hygiene.md` |
| CC-H2 | Dead code | `hygiene.md` |
| CC-H3 | Premature abstraction | `hygiene.md` |
| CC-F1 | Component size | `frontend.md` |
| CC-F2 | Props interface | `frontend.md` |
| CC-F3 | Logic extraction | `frontend.md` |

## What this skill does NOT cover

These concerns are owned by other skills/commands — do not duplicate:
- Logging patterns → `skills/production-hardening/`
- Error handling, retry, timeout → `skills/production-hardening/`
- Auth patterns → `skills/production-hardening/`
- Import style, naming case (camelCase vs snake_case) → pattern fingerprint
- Cyclomatic complexity scoring → `/architect:complexity-check`
- Security vulnerabilities → `/architect:review` Check 3, `/architect:security-scan`
- Architecture layer violations (logic in route, cross-component imports) → `/architect:review` Check 5

---

## Severity Table

| Rule | Severity | Rationale |
|------|---------|-----------|
| CC-S1 function length | WARNING | Structure debt — not immediately broken |
| CC-S2 single responsibility | WARNING | Same class of issue as CC-S1 |
| CC-S3 abstraction levels | SUGGEST | Subtle and context-dependent |
| CC-N1 meaningful names | WARNING | Generic names accumulate into readability debt across the codebase |
| CC-N2 magic values | WARNING | Unexplained literals create silent maintenance hazards |
| CC-I1 parameter count | WARNING | Design smell — signals a missing abstraction |
| CC-I2 boolean trap | SUGGEST | Unreadable at call site but logic is correct |
| CC-H1 DRY | SUGGEST at 2 occurrences / WARNING at 3+ | Reviewer must count before assigning |
| CC-H2 dead code | WARNING | Misleads readers, pollutes git blame |
| CC-H3 premature abstraction | WARNING | Directly violates CLAUDE.md: "Don't create helpers for one-time operations" |
| CC-F1 component size | WARNING | Monolithic components block reuse and testing |
| CC-F2 props interface | WARNING | Over-coupled components indicate decomposition is needed |
| CC-F3 logic extraction | SUGGEST | Logic in render functions works but is harder to test |

No clean-code rule is a BLOCKER. Blockers are reserved for security vulnerabilities, broken builds, and architectural violations with immediate production impact.

---

## Implementer Read Protocol

Read `SKILL.md` (this file) once at the start of the write session to get the severity table and sub-file map. Then read only the sub-files relevant to the layer you are about to write.

Apply rules as **design constraints during writing** — not as post-hoc detectors. Fix before moving to the next function.

| Layer | Sub-files to read | Key rules |
|-------|------------------|-----------|
| Schema / validation | `naming.md` + `interface.md` | CC-N1, CC-N2, CC-I1 |
| Service layer | `structure.md` + `naming.md` + `interface.md` + `hygiene.md` | All 10 backend rules |
| Route / controller | `structure.md` + `interface.md` | CC-S1, CC-S2, CC-I2 |
| Integration lib | `naming.md` + `hygiene.md` | CC-N1, CC-H3 |
| Test layer | `hygiene.md` | CC-H1, CC-H2 |
| Frontend component | `frontend.md` + `naming.md` | CC-F1, CC-F2, CC-F3, CC-N1 |

**During writing — apply in this order:**
1. Before writing a function signature: apply CC-I1 (parameter count) and CC-N1 (naming). Fix before writing the body.
2. After writing the function body: apply CC-S1 (length). If it exceeds the threshold, decompose before continuing.
3. After writing a file: apply CC-H2 (dead code) and CC-H3 (premature abstraction).
4. When copying a logic block from earlier in the session: apply CC-H1 (DRY) — if copying a second time, extract first.
5. For frontend files: apply CC-F1 (component size) before writing the JSX/template return — design the component hierarchy first if threshold is likely to be exceeded.

---

## Scaffolder Read Protocol

The scaffolder reads `naming.md` + `hygiene.md` before generating any file. Apply the following rules only:

| Rule | Applies | Note |
|------|---------|------|
| CC-N1 meaningful names | Yes | Template names become the codebase baseline |
| CC-N2 magic values | Yes | No hardcoded ports/timeouts/limits in generated files |
| CC-H2 dead code | Yes — critical | No TODOs, no commented-out blocks in generated scaffold files |
| CC-H3 premature abstraction | Yes — critical | Do not generate single-use utility wrappers |
| CC-S1 function length | Yes | Template functions should not be monolithic |
| CC-H1 DRY | Partial | 3+ occurrences rule only — scaffold legitimately repeats patterns |

Rules that do NOT apply to scaffold: CC-S2, CC-S3, CC-I1, CC-I2, CC-F1, CC-F2, CC-F3.

---

## Reviewer Reference Map

The reviewer reads `SKILL.md` first to determine which sub-files are relevant based on the diff content. It does not read all sub-files for every review.

| Reviewer check | Sub-files to read | Findings added |
|---------------|------------------|----------------|
| Check 1 — Pattern conformance | `naming.md` + `hygiene.md` + `interface.md` (if new functions with many params or boolean args are present) | `cleancode-naming`, `cleancode-magic-value`, `cleancode-premature-abstraction`, `cleancode-dead-code`, `cleancode-param-count`, `cleancode-boolean-trap` |
| Check 4 — Test coverage | `hygiene.md` (CC-H2 only — dead code in test files: commented-out test cases, unused helpers) | `cleancode-dead-code` |
| Check 5 — Architecture fitness | `structure.md` + `frontend.md` (if diff includes frontend files) | `cleancode-fn-length`, `cleancode-single-responsibility`, `cleancode-abstraction-levels`, `cleancode-component-size`, `cleancode-props-interface`, `cleancode-logic-extraction` |

**Check IDs** (`check` field in findings result contract):

```
cleancode-fn-length
cleancode-single-responsibility
cleancode-abstraction-levels
cleancode-naming
cleancode-magic-value
cleancode-param-count
cleancode-boolean-trap
cleancode-dry
cleancode-dead-code
cleancode-premature-abstraction
cleancode-component-size
cleancode-props-interface
cleancode-logic-extraction
```
