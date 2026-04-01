# Clean Code — Hygiene Rules

Rules CC-H1, CC-H2, CC-H3. Loaded by the implementer for all layers and by the scaffolder. Referenced by the reviewer in Check 1 and Check 4.

---

## CC-H1: DRY (Don't Repeat Yourself)

### Trigger — implementer

When copying or rewriting a logic block from earlier in the same write session, or from an existing file found by Grep:

- **2 occurrences in the same file** → extract to a named function in that file
- **3+ occurrences anywhere in the component** → extract to a named function in a shared module
- **2 occurrences across different files** → do NOT extract yet. Add a `// sync-candidate` comment on both. Extract when a third call site appears.

The "later if needed" approach guarantees the abstraction has proven its value before it exists.

### Trigger — reviewer

In the diff's added content, search for strings of 4+ consecutive identical lines appearing in 2+ locations. Use Grep on the component directory for the duplicated block to determine the total occurrence count before assigning severity.

- 2 occurrences in same file → SUGGEST (extract)
- 2 occurrences across files → SUGGEST (add `// sync-candidate` comment)
- 3+ occurrences anywhere → WARNING (extract now)

### Constraint

Extract the shared logic to a named function. Place it:
- In the same file, if used only within that file
- In a shared module (`utils/<domain>.ts`, `app/utils/<domain>.py`, `internal/<domain>/helpers.go`), if used across files

Do NOT create a shared utility file for a function used in exactly one place — that is CC-H3 (premature abstraction).

### Before / After

```python
# BEFORE — same error dict built in 3 route handlers
# orders.py
return JSONResponse({"status": "error", "message": str(e), "code": "ORDER_FAILED"}, 422)

# products.py
return JSONResponse({"status": "error", "message": str(e), "code": "PRODUCT_FAILED"}, 422)

# users.py
return JSONResponse({"status": "error", "message": str(e), "code": "USER_FAILED"}, 422)

# AFTER — extracted to shared helper (3 occurrences justifies extraction)
# app/utils/responses.py
def error_response(message: str, code: str, status: int = 422) -> JSONResponse:
    return JSONResponse({"status": "error", "message": message, "code": code}, status)

# orders.py, products.py, users.py
return error_response(str(e), "ORDER_FAILED")
```

---

## CC-H2: Dead Code

### Trigger — implementer

Do not write it. Before committing a file, scan for:
- Commented-out code blocks (lines that are only a comment containing what appears to be code)
- Parameters the function body never references
- `else` / `elif` branches after a `return`, `throw`, `raise`, or `panic` in the preceding `if`
- Variables assigned but never read
- Imports that are never used in the file

Remove each before moving on.

### Trigger — reviewer

Scan added lines in non-test files for:

| Dead code type | Detection pattern |
|---------------|-----------------|
| Commented-out code | Multi-line comment block where lines start with `//`, `#`, `--` and contain assignment (`=`), function call (`(`), or control flow (`if`, `for`, `return`) patterns |
| Unreachable else | `else` or `elif` block that immediately follows a branch ending in `return`/`throw`/`raise`/`panic` — the else is never reached |
| Unused parameter | Parameter name in function signature that does not appear in the function body (use whole-word match to avoid false positives on partial name matches) |
| Unused variable | Variable assigned (e.g. `const x =`, `x :=`, `x = `) but `x` never appears again in the function scope |
| Unused import | Import statement for a module/symbol that is not referenced in any added line of the file |

Scan added lines in test files for:
- Commented-out test cases (comment block containing `it(`, `def test_`, `func Test`, `[Test]`, `@Test`)
- Unused test helper functions called from nowhere in the test file

### Constraint

Remove dead code completely. If code is preserved for historical reference, it belongs in git history — not in the file. If a parameter must be kept for interface compatibility, mark it as intentionally unused:

| Runtime | Intentionally unused parameter pattern |
|---------|---------------------------------------|
| TypeScript | `_paramName` prefix |
| Python | `_param_name` prefix |
| Go | `_` or `_ TypeName` |
| .NET | `#pragma warning disable IDE0060` + comment explaining why (sparingly) |
| Java | `@SuppressWarnings("unused")` + comment explaining why (sparingly) |
| Swift | `_ paramName` in function signature |
| Kotlin | `@Suppress("UNUSED_PARAMETER")` + comment (sparingly) |

When using the unused-parameter pattern, add a comment on the function explaining why the parameter exists (interface contract, future use with a known issue, etc.).

### Before / After

```typescript
// BEFORE — dead code on three dimensions
async function updateUserEmail(userId: string, email: string, options: UpdateOptions) {
  // const user = await userRepo.findById(userId)
  // if (!user) return null
  // logger.info('found user', { userId })

  const result = await userRepo.updateEmail(userId, email)

  if (!result) {
    throw new NotFoundError('User not found')
  } else {
    // unreachable — the throw above means we never reach here via the false branch
    return result
  }
}

// AFTER — dead code removed; unreachable else collapsed
async function updateUserEmail(userId: string, email: string, _options: UpdateOptions) {
  // _options reserved for future rate-limit context (tracked in issue #412)
  const user = await userRepo.updateEmail(userId, email)
  if (!user) throw new NotFoundError('User not found')
  return user
}
```

---

## CC-H3: Premature Abstraction

### Trigger — implementer

Do not create a helper function, utility module, shared library, or wrapper for logic that is used in **exactly one place**. Write the logic inline. Extract only when a second call site is introduced.

This directly enforces the plugin's own CLAUDE.md constraint: "Don't create helpers, utilities, or abstractions for one-time operations."

Before creating any new utility/helper function, answer: "Where is the second call site?" If you cannot answer that question, write it inline.

### Trigger — reviewer

Scan the diff for:
1. New files in `utils/`, `helpers/`, `lib/`, `shared/`, `common/` directories that contain functions
2. New functions with names ending in `Helper`, `Util`, `Utils`, `Factory`, `Builder` (outside of established factory/builder patterns already in the codebase)
3. New wrapper functions that add no logic — they call through to another function with the same parameters

For each found: Grep the component directory for call sites of the new function. If only one call site exists in the entire diff + existing code → WARNING.

**Exceptions — do NOT flag:**
- Abstractions required by a framework (NestJS `@Injectable()` providers, Angular services, Spring `@Component` beans) — the framework mandates the abstraction even for single use
- Wrappers around third-party APIs in `lib/` or `integrations/` — these exist to enable mocking in tests and to isolate external dependencies, which is the correct pattern even with one call site
- Abstractions with a comment explicitly noting they are designed for a second call site that is in-flight (tracked in an issue)

### Constraint

Inline the logic at the single call site. Delete the single-use helper/utility. If the code is genuinely complex and warrants a name for readability, extract it as a **private/unexported function in the same file** — not in a shared utility module.

The question is not "could this be reused?" but "is it reused?". Three similar lines of code in one file are better than a premature shared abstraction.

### Before / After

```go
// BEFORE — single-use utility file created for one caller
// utils/format.go
package utils

func FormatOrderSummary(order *Order) string {
    return fmt.Sprintf("Order #%s — %d items — $%.2f", order.ID, len(order.Items), order.Total)
}

// handlers/orders.go — the only caller
import "myapp/utils"
summary := utils.FormatOrderSummary(order)
logger.Info("order processed", "summary", summary)

// AFTER — logic inlined at the single call site; utils/format.go deleted
// handlers/orders.go
summary := fmt.Sprintf("Order #%s — %d items — $%.2f", order.ID, len(order.Items), order.Total)
logger.Info("order processed", "summary", summary)

// When a second call site appears in a different handler, extract then:
// handlers/orders.go + handlers/refunds.go both need it → extract to formatOrderSummary()
// in handlers/orders.go (unexported, same package) until a third package needs it.
```
