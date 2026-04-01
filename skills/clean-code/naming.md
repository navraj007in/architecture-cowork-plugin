# Clean Code — Naming Rules

Rules CC-N1, CC-N2. Loaded by the implementer for all layers and by the scaffolder. Referenced by the reviewer in Check 1 (pattern conformance).

---

## CC-N1: Meaningful Names

### Trigger — implementer

Before committing any name (variable, function, parameter, class, module), verify it passes all four tests:

1. **Describes intent, not implementation** — the name says what it represents or does, not how it does it
2. **No unexplained abbreviations** — universally known domain acronyms are acceptable (`id`, `url`, `http`, `api`, `dto`, `db`, `ctx`, `req`, `res` in HTTP handler scope); all others must be spelled out
3. **Not a generic term** — the blocklist below applies
4. **Predictable from the name alone** — a reader unfamiliar with the implementation can predict what the function returns or what the variable holds just from reading the name

### Trigger — reviewer

Scan added lines for variable, parameter, and function names matching the generic name blocklist. Flag each occurrence.

**Generic name blocklist** (flag as WARNING):

`data`, `result`, `temp`, `tmp`, `value`, `val`, `obj`, `item`, `thing`, `stuff`, `info`, `ret`, `out`, `buf`, `response` (as a local variable — not as an HTTP response parameter named `res`), `payload` (as a final return value — acceptable as a parameter name for incoming request bodies), `handler` (as a local variable — acceptable as a parameter name in middleware), `helper`, `util`, `manager` (as a class suffix when the class has a clear domain name that makes `Manager` redundant)

**Exceptions** — do NOT flag:
- `req`, `res` in HTTP route handlers (framework convention, universally understood)
- `ctx` in Go and middleware contexts (framework convention)
- `err` in Go (idiomatic, universally understood)
- `i`, `j`, `k` as loop counters in short loops (< 5 lines)
- `e` or `ex` as exception variable in catch blocks
- `_` as intentionally unused (Go, Python, TypeScript)

### Constraint

Names encode the domain concept and the type of value. The `Data` and `Info` suffixes are almost always meaningless — remove them. `userData` → `user`. `productInfo` → `product`. `orderData` → `order`.

Names for booleans should read as a yes/no question: `isActive`, `hasPermission`, `canRefund`, `wasNotified`. Not: `active`, `permission`, `refund`, `notified`.

Names for functions should be verb-noun pairs: `calculateRefundAmount`, `findOrderById`, `sendWelcomeEmail`. Not: `refund`, `order`, `email`.

### Before / After

```go
// BEFORE — generic names throughout
func processData(data interface{}) (interface{}, error) {
    result := make(map[string]interface{})
    temp := data.(map[string]interface{})
    val, ok := temp["user_id"]
    if !ok {
        return nil, fmt.Errorf("missing field")
    }
    result["info"] = val
    return result, nil
}

// AFTER — domain-specific names
func extractUserIdFromWebhook(payload WebhookPayload) (string, error) {
    userId, ok := payload["user_id"]
    if !ok {
        return "", fmt.Errorf("webhook payload missing required field: user_id")
    }
    return userId.(string), nil
}
```

---

## CC-N2: Magic Values

### Trigger — implementer

Any numeric or string literal that is not one of the following must be a named constant before using it in the function body:
- `0`, `1`, `-1` (boundary/sentinel values where the meaning is obvious from context)
- `""`, `null`, `nil`, `None`, `undefined` (empty/null checks)
- `true`, `false`
- HTTP status codes used directly in route handlers (e.g. `404`, `200`, `422`) — these are universally understood in that context
- String literals in log messages and error messages (these are human-readable prose, not magic values)
- String literals in test assertions (test expected values are intentionally literal)

### Trigger — reviewer

Scan added lines for:
- Numeric literals > `1` outside of array index expressions and loop increment/decrement
- String literals > 3 characters outside of: log/error messages, test files, config comments, import paths, SQL/template strings where the literal is the query itself

For each found, check if a named constant with that value is already defined in scope. If not → WARNING.

### Constraint

Extract to a named constant at the appropriate scope. The constant name explains **why this value exists**, not what it is numerically.

Good: `MAX_LOGIN_ATTEMPTS = 5`, `SESSION_TIMEOUT_SECONDS = 3600`, `DESCRIPTION_MAX_LENGTH = 255`
Bad: `FIVE = 5`, `THREE_THOUSAND_SIX_HUNDRED = 3600`, `TWO_FIFTY_FIVE = 255`

Group related constants in a config object, enum, or constants module if 3+ constants share a logical domain.

### Where to declare constants by runtime

| Runtime | Declaration pattern |
|---------|-------------------|
| TypeScript | `const MAX_LOGIN_ATTEMPTS = 5 as const` at module scope; group related: `export const AuthLimits = { maxAttempts: 5, lockoutSeconds: 900 } as const` |
| Python | `MAX_LOGIN_ATTEMPTS = 5` at module scope; or `class AuthConfig:` dataclass for grouped constants |
| Go | `const maxLoginAttempts = 5` (unexported if component-local); `const MaxLoginAttempts = 5` (exported if used across packages) |
| .NET / C# | `private const int MaxLoginAttempts = 5;` on the class; or `public static class AuthConstants` for shared |
| Java | `private static final int MAX_LOGIN_ATTEMPTS = 5;` on the class; or dedicated `Constants` class |
| Swift | `private let maxLoginAttempts = 5` at class scope; or `enum AuthConstants` for namespace |
| Kotlin | `private const val MAX_LOGIN_ATTEMPTS = 5` companion object; or top-level `const val` |

### Before / After

```python
# BEFORE — magic values everywhere
async def lock_account_if_needed(user_id: str, db: AsyncSession) -> None:
    attempts = await get_failed_attempts(user_id, db)
    if attempts >= 5:
        await db.execute(
            update(User).where(User.id == user_id)
            .values(locked=True, locked_until=datetime.utcnow() + timedelta(seconds=900))
        )
        await db.commit()

# AFTER — named constants explain the domain rules
MAX_FAILED_LOGIN_ATTEMPTS = 5
ACCOUNT_LOCKOUT_DURATION_SECONDS = 900

async def lock_account_if_needed(user_id: str, db: AsyncSession) -> None:
    attempts = await get_failed_attempts(user_id, db)
    if attempts >= MAX_FAILED_LOGIN_ATTEMPTS:
        lockout_until = datetime.utcnow() + timedelta(seconds=ACCOUNT_LOCKOUT_DURATION_SECONDS)
        await db.execute(
            update(User).where(User.id == user_id)
            .values(locked=True, locked_until=lockout_until)
        )
        await db.commit()
```
