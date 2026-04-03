---
name: clean-code
description: Structural code quality rules applied at write time (implementer, scaffolder) and check time (reviewer). Covers function length, single responsibility, abstraction levels, meaningful naming, magic values, parameter design, boolean traps, DRY, dead code, premature abstraction, frontend component decomposition, null safety, async safety, input validation at boundaries, and concurrency safety.
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
| CC-NS1 | No unguarded nullable access | `null-safety.md` |
| CC-NS2 | No non-null assertion | `null-safety.md` |
| CC-NS3 | Declare nullable return types | `null-safety.md` |
| CC-NS4 | Guard collection access | `null-safety.md` |
| CC-NS5 | Validate external data before use | `null-safety.md` |
| CC-NS6 | Propagate null, do not swallow | `null-safety.md` |
| CC-AS1 | Every promise must be awaited | `async-safety.md` |
| CC-AS2 | Do not mix async styles | `async-safety.md` |
| CC-AS3 | Async errors must propagate | `async-safety.md` |
| CC-AS4 | No parallel state mutation | `async-safety.md` |
| CC-AS5 | Timeout on all external async calls | `async-safety.md` |
| CC-IV1 | Validate request body before use | `input-validation.md` |
| CC-IV2 | Validate path and query params | `input-validation.md` |
| CC-IV3 | Sanitise string inputs | `input-validation.md` |
| CC-IV4 | Validate env vars at startup | `input-validation.md` |
| CC-IV5 | Reject unknown fields | `input-validation.md` |
| CC-CS1 | No mutable loop variable capture | `concurrency-safety.md` |
| CC-CS2 | Correct React state update pattern | `concurrency-safety.md` |
| CC-CS3 | Module-level singletons must be concurrency-safe | `concurrency-safety.md` |
| CC-CS4 | No non-atomic paired reads | `concurrency-safety.md` |
| CC-CS5 | Idempotency keys for state-mutating ops | `concurrency-safety.md` |

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
| CC-NS1 unguarded nullable access | BLOCKER | Directly causes TypeError/AttributeError/nil pointer dereference in production |
| CC-NS2 non-null assertion | WARNING | Bypasses the type system — generated code must not use it |
| CC-NS3 undeclared nullable return | WARNING | Callers cannot write safe code against undeclared nullable returns |
| CC-NS4 unguarded collection access | BLOCKER | Index out of bounds / undefined on empty collections crashes in production |
| CC-NS5 unvalidated external data | BLOCKER | Malformed external data causes crashes or silent data corruption |
| CC-NS6 null swallowed in service | WARNING | Hides absence from caller — leads to wrong-data bugs |
| CC-AS1 unawaited promise | BLOCKER | Silent failure — errors swallowed and operations silently skip |
| CC-AS2 mixed async styles | WARNING | Confusing control flow and inconsistent error propagation |
| CC-AS3 async error swallowed | BLOCKER | Caller cannot detect failure — same production impact as CR-E1 |
| CC-AS4 parallel state mutation | WARNING | Non-deterministic results; data races in non-JS runtimes |
| CC-AS5 no timeout on external call | WARNING | Hangs indefinitely under network partition or slow dependency |
| CC-IV1 unvalidated request body | BLOCKER | Type confusion, panics, or injection when unvalidated fields reach DB or logic |
| CC-IV2 unvalidated path/query params | BLOCKER | Type coercion failures, invalid DB queries, injection via malformed IDs |
| CC-IV3 unsanitised string inputs | WARNING | Length violations cause DB errors; unsanitised HTML output is XSS |
| CC-IV4 unvalidated env vars | WARNING | Config errors surface at runtime, not at startup |
| CC-IV5 unknown fields passed through | WARNING | Mass-assignment risk — escalates to BLOCKER if ORM binds the full body |
| CC-CS1 mutable loop variable capture | BLOCKER | All closures reference the same final value — silent logic error |
| CC-CS2 stale closure in React state | WARNING | Non-deterministic state updates under rapid interaction |
| CC-CS3 unprotected shared mutable state | WARNING | Safe in Node.js but data race in Go/.NET/Python threaded contexts |
| CC-CS4 non-atomic paired reads | WARNING | TOCTOU window — accept or mitigate with a single atomic query |
| CC-CS5 non-idempotent mutation | WARNING | Duplicate charges/records under retry — escalates to BLOCKER for payments |

**BLOCKERs in this skill:** CC-NS1, CC-NS4, CC-NS5, CC-AS1, CC-AS3, CC-IV1, CC-IV2, CC-CS1. These are safety rules that cause runtime crashes or silent failures — not style issues.

---

## Implementer Read Protocol

Read `SKILL.md` (this file) once at the start of the write session to get the severity table and sub-file map. Then read only the sub-files relevant to the layer you are about to write.

Apply rules as **design constraints during writing** — not as post-hoc detectors. Fix before moving to the next function.

| Layer | Sub-files to read | Key rules |
|-------|------------------|-----------|
| Schema / validation | `naming.md` + `interface.md` + `null-safety.md` + `input-validation.md` | CC-N1, CC-N2, CC-I1, CC-NS3, CC-NS5, CC-IV3, CC-IV5 |
| Service layer | `structure.md` + `naming.md` + `interface.md` + `hygiene.md` + `null-safety.md` + `async-safety.md` | All backend rules + all NS + AS rules |
| Route / controller | `structure.md` + `interface.md` + `null-safety.md` + `input-validation.md` | CC-S1, CC-S2, CC-I2, CC-NS1, CC-NS4, CC-IV1, CC-IV2, CC-IV3, CC-IV5 |
| Integration lib | `naming.md` + `hygiene.md` + `null-safety.md` + `async-safety.md` | CC-N1, CC-H3, CC-NS1, CC-NS5, CC-AS1, CC-AS5 |
| Test layer | `hygiene.md` | CC-H1, CC-H2 |
| Frontend component | `frontend.md` + `naming.md` + `null-safety.md` + `concurrency-safety.md` | CC-F1, CC-F2, CC-F3, CC-N1, CC-NS1, CC-NS4, CC-CS1, CC-CS2 |
| Config / startup | `input-validation.md` | CC-IV4 |

**During writing — apply in this order:**
1. Before writing a function signature: apply CC-I1 (parameter count), CC-N1 (naming), and CC-NS3 (declare nullable return type if the function can return null/undefined/None).
2. For route handlers: apply CC-IV1 and CC-IV2 — write the schema parse as the first statement before any field access.
3. After every call to a DB query, external API, or collection lookup: apply CC-NS1 (null guard) and CC-NS4 (collection guard) — place the guard immediately before any property access.
4. After every `async` function call: apply CC-AS1 — ensure `await` is present or the Promise is explicitly returned/handled.
5. After writing the function body: apply CC-S1 (length). Decompose before continuing if over threshold.
6. After writing a file: apply CC-H2 (dead code) and CC-H3 (premature abstraction).
7. When copying a logic block: apply CC-H1 (DRY) — extract before copying a second time.
8. For frontend files: apply CC-F1 (component size) before writing JSX return; apply CC-CS2 for any `setState` that depends on previous state.
9. For loop bodies with closures or goroutines: apply CC-CS1 — verify the loop variable is correctly bound.
10. Whenever consuming external data (API response, env var, IPC payload, DB row): apply CC-NS5 and CC-IV1 — validate shape before accessing fields.

---

## Scaffolder Read Protocol

The scaffolder reads `naming.md` + `hygiene.md` + `null-safety.md` + `async-safety.md` + `input-validation.md` + `concurrency-safety.md` before generating any file.

| Rule | Applies | Note |
|------|---------|------|
| CC-N1 meaningful names | Yes | Template names become the codebase baseline |
| CC-N2 magic values | Yes | No hardcoded ports/timeouts/limits in generated files |
| CC-H2 dead code | Yes — critical | No TODOs, no commented-out blocks in generated scaffold files |
| CC-H3 premature abstraction | Yes — critical | Do not generate single-use utility wrappers |
| CC-S1 function length | Yes | Template functions should not be monolithic |
| CC-H1 DRY | Partial | 3+ occurrences rule only — scaffold legitimately repeats patterns |
| CC-NS1 unguarded nullable access | Yes — critical | Every DB lookup/find-by-id must have a null guard before property access |
| CC-NS2 non-null assertion | Yes — banned | Never emit `!` assertions or `!!` in generated code |
| CC-NS3 nullable return types | Yes — critical | Repository/service functions that can return null must declare it |
| CC-NS4 collection access guard | Yes — critical | Never generate `items[0].x` or `.find().x` without a prior guard |
| CC-NS5 validate external data | Yes — critical | Never emit bare `(await res.json()) as T`; always validate first |
| CC-NS6 propagate null | Yes | Service layer throws or returns typed null — not empty default objects |
| CC-AS1 await every promise | Yes — critical | Never generate a floating async call without `await` or explicit handling |
| CC-AS2 consistent async style | Yes | Never mix `await` and `.then()` chains in the same generated function |
| CC-AS3 propagate async errors | Yes — critical | No bare `catch { return null }` in service or integration layers |
| CC-AS5 timeout on external calls | Yes | Every generated HTTP/DB call stub must include a timeout |
| CC-IV1 validate request body | Yes — critical | First statement of every generated POST/PUT/PATCH handler must be a schema parse |
| CC-IV2 validate path/query params | Yes — critical | Never pass `req.params.*` or `req.query.*` directly to a repo call |
| CC-IV3 sanitise strings | Yes | Generated schemas must include `.trim().min(1).max(N)` on string fields |
| CC-IV4 validate env vars at startup | Yes — critical | Generated config module must validate all env vars at process start |
| CC-IV5 reject unknown fields | Yes | Generated request schemas must use `.strict()` or `extra='forbid'` |
| CC-CS1 loop variable capture | Yes — critical | Go goroutines must copy loop var; JS must use `let` not `var` in loops |
| CC-CS2 React state updates | Yes | `setState` depending on previous value must use functional updater form |
| CC-CS5 idempotency keys | Yes | Generated payment routes and queue consumers must include idempotency/dedup check |

Rules that do NOT apply to scaffold: CC-S2, CC-S3, CC-I1, CC-I2, CC-F1, CC-F2, CC-F3, CC-AS4, CC-CS3, CC-CS4.

---

## Reviewer Reference Map

The reviewer reads `SKILL.md` first to determine which sub-files are relevant based on the diff content.

| Reviewer check | Sub-files to read | Findings added |
|---------------|------------------|----------------|
| Check 1 — Pattern conformance | `naming.md` + `hygiene.md` + `null-safety.md` + `async-safety.md` + `input-validation.md` + `concurrency-safety.md` + `interface.md` (if new functions with many params) | All check IDs below |
| Check 4 — Test coverage | `hygiene.md` (CC-H2 only) | `cleancode-dead-code` |
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
cleancode-null-unguarded
cleancode-null-assertion
cleancode-null-return-type
cleancode-null-collection
cleancode-null-external
cleancode-null-swallowed
cleancode-async-unawaited
cleancode-async-mixed-style
cleancode-async-error-swallowed
cleancode-async-parallel-mutation
cleancode-async-no-timeout
cleancode-iv-body-unvalidated
cleancode-iv-params-unvalidated
cleancode-iv-string-unsanitised
cleancode-iv-env-unvalidated
cleancode-iv-unknown-fields
cleancode-cs-loop-capture
cleancode-cs-stale-closure
cleancode-cs-shared-mutable
cleancode-cs-nonatomic-reads
cleancode-cs-nonidempotent
```
