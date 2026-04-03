# Null Safety

Rules CC-NS1 through CC-NS6. Apply at **write time** (scaffolder and implementer) and **review time** (reviewer Check 1). These are generation constraints — generated code must never contain an unguarded null/undefined access.

---

## CC-NS1 — No Unguarded Property Access on Nullable Value

Before accessing a property or calling a method on a value that could be `null`, `undefined`, `None`, `nil`, or a pointer, confirm the value is non-null at that point or use a safe access operator.

| Runtime | Unsafe pattern | Safe pattern |
|---------|---------------|-------------|
| TypeScript | `user.name` where `user` is typed `User \| null \| undefined` | `user?.name` or guard: `if (!user) return` |
| TypeScript | `res.data.items[0].id` on an API response | `res.data?.items?.[0]?.id` or explicit checks |
| Python | `user.name` where `get_user()` can return `None` | `if user is None: return` before access, or `user.name if user else default` |
| Go | `user.Name` where `user` is a pointer `*User` | `if user == nil { return }` before dereference |
| Go | `m[key].Field` on a map that may not have the key | `val, ok := m[key]; if !ok { return }` |
| Java | `user.getName()` where `findUser()` returns `Optional<User>` | `user.map(User::getName).orElse(null)` or `.orElseThrow()` |
| .NET | `user.Name` where `FindUser()` can return `null` | Null-conditional: `user?.Name` or null check before access |

**At scaffold/implement time:** every function that calls a database query, external API, or collection lookup must treat the result as nullable. Place the null guard as the first statement after the call — before any property access.

---

## CC-NS2 — No Non-Null Assertion Without Proof

Non-null assertion operators bypass the type system. Generated code must not use them.

| Runtime | Banned pattern | Allowed alternative |
|---------|---------------|-------------------|
| TypeScript | `user!.name` | Add a preceding `if (!user) throw new NotFoundError(...)` then access `user.name` |
| TypeScript | `document.getElementById('x')!` | `const el = document.getElementById('x'); if (!el) return;` |
| Kotlin | `user!!.name` | Null-safe call `user?.name` or explicit check |
| Swift | `user!.name` | `guard let user = user else { return }` |

**Exception:** Non-null assertion is acceptable only when the value was assigned in the same block immediately after an explicit null throw/return.

---

## CC-NS3 — Function Return Types Must Declare Nullability

A function that can return null or undefined must declare that in its return type. Callers cannot write safe code against undeclared nullable returns.

| Runtime | Unsafe pattern | Required pattern |
|---------|---------------|-----------------|
| TypeScript | `function getUser(id: string): User` — but returns `null` on not-found | `function getUser(id: string): User \| null` |
| Python | `def get_user(id: str) -> User:` — but returns `None` | `def get_user(id: str) -> Optional[User]:` or `User \| None` (3.10+) |
| Go | Pointer return `*User` is self-documenting — caller must nil-check | No change needed |
| Java | `User findUser(String id)` returning `null` | `Optional<User> findUser(String id)` |
| .NET | `User? FindUser(string id)` with nullable reference types enabled | Already correct — enable `<Nullable>enable</Nullable>` in project |

**Scaffolder rule:** Generated repository and service functions that perform DB lookups must always include the null variant in the return type. Never generate `findById` functions with a non-nullable return type.

---

## CC-NS4 — Array / Collection Access Must Handle Empty

Accessing the first element of a collection, slicing, or indexing assumes the collection is non-empty. Generated code must check before accessing by index.

| Runtime | Unsafe pattern | Safe pattern |
|---------|---------------|-------------|
| TypeScript | `items[0].id` | `items[0]?.id` or `if (items.length === 0) return` |
| TypeScript | `items.find(x => x.id === id).name` | `items.find(x => x.id === id)?.name` |
| Python | `items[0]` | `items[0] if items else default` or `if not items: return` |
| Go | `items[0]` | `if len(items) == 0 { return }` |
| Java | `items.get(0)` | `if (items.isEmpty()) return;` or `items.stream().findFirst().orElse(null)` |
| .NET | `items[0]` | `items.FirstOrDefault()` |

**At scaffold/implement time:** any generated code that calls `.find()`, `.filter()[0]`, `.first()`, `.get(index)`, or equivalent must not chain a property access on the result without a null guard.

---

## CC-NS5 — External Data Must Be Validated Before Use

Data arriving from external sources (HTTP responses, database rows, environment variables, user input, IPC messages) must be treated as potentially malformed — not assumed to match the expected shape.

| Source | Unsafe pattern | Required pattern |
|--------|---------------|-----------------|
| HTTP response (TypeScript) | `const data = await res.json() as MyType; doSomething(data.field)` | Parse with Zod/Valibot before use; catch parse errors |
| HTTP response (Python) | `data = response.json(); do_something(data['field'])` | `data.get('field')` or validate with Pydantic before use |
| Database row (TypeScript/Prisma) | `const row = await db.findFirst(...); return row.field` | `if (!row) throw new NotFoundError(...)` |
| Environment variable | `const port = process.env.PORT` used as number | `const port = parseInt(process.env.PORT ?? '3000', 10)` |
| IPC / event payload | `event.data.userId` | Validate shape with a type guard or schema before destructuring |

**Scaffolder rule:** Generated API client functions must validate the response body. Never generate `return await res.json() as T` — always wrap in a validation step or at minimum check `res.ok` before parsing.

---

## CC-NS6 — Propagate Null Upward, Do Not Swallow It

When a function receives a null result, it must either handle it explicitly (throw, return a default) or propagate the null in its own return type. Silently converting null to a default value is only acceptable at the UI/API response boundary.

| Anti-pattern | Why it is wrong | Required alternative |
|-------------|----------------|---------------------|
| `return user ?? {}` in a service function | Caller receives a fake empty object and cannot detect absence | `if (!user) throw new NotFoundError('User', id)` |
| `return user \|\| null` in a repository typed `User` | Breaks the type contract | Change return type to `User \| null` |
| `const name = user?.name \|\| ''` in a service | Treats absence and empty string as equivalent | `if (!user) throw ...` — handle absence as a distinct case |
| `result = result or {}` in Python service | Same as first row | Raise `NotFoundError` |

**Exception:** At the API response layer (route handler / React component rendering), collapsing null to a default (`''`, `[]`, `0`, `'—'`) is intentional and correct.

---

## Severity

| Rule | Severity | Rationale |
|------|---------|-----------|
| CC-NS1 unguarded access | BLOCKER | Directly causes `TypeError`, `AttributeError`, nil pointer dereference — crashes in production |
| CC-NS2 non-null assertion | WARNING | Bypasses the type system — generated code must not use it |
| CC-NS3 undeclared nullable return | WARNING | Callers cannot write safe code — forces implicit assumptions |
| CC-NS4 unguarded collection access | BLOCKER | Index out of bounds / undefined access on empty collections — crashes in production |
| CC-NS5 unvalidated external data | BLOCKER | Malformed external data crashes or corrupts state silently |
| CC-NS6 null swallowed in service | WARNING | Hides absence from caller — leads to wrong-data bugs |

CC-NS1, CC-NS4, and CC-NS5 are BLOCKERs — they cause runtime crashes or silent data corruption.
