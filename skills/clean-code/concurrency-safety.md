# Concurrency Safety

Rules CC-CS1 through CC-CS5. Apply at **write time** (scaffolder and implementer) and **review time** (reviewer Check 1). Generated code must not introduce shared mutable state, stale closures, or data races.

---

## CC-CS1 — Do Not Capture Mutable Loop Variables in Closures

Closures that capture a loop variable by reference all refer to the same variable after the loop finishes.

| Runtime | Unsafe pattern | Safe pattern |
|---------|---------------|-------------|
| JavaScript (`var`) | `for (var i = 0; i < n; i++) { setTimeout(() => console.log(i), 0); }` — all print `n` | Use `let`: `for (let i = 0; i < n; i++)` — block-scoped per iteration |
| Go | `for _, v := range items { go func() { process(v) }() }` — all goroutines may capture the same `v` | Copy explicitly: `for _, v := range items { v := v; go func() { process(v) }() }` or pass as arg: `go func(v T) { process(v) }(v)` |
| Python | `funcs = [lambda: x for x in range(3)]` — all lambdas return `2` | `funcs = [lambda x=x: x for x in range(3)]` — default arg captures by value |

**Scaffolder rule:** Never generate `var` in loops. Always use `let`/`const`. In Go goroutine generation, always copy the loop variable before the closure.

---

## CC-CS2 — Use Correct React State Update Pattern

React state updates are asynchronous. Reading state inside a closure may return a stale value.

| Unsafe pattern | Why | Safe pattern |
|---------------|-----|-------------|
| `setCount(count + 1)` called multiple times rapidly | `count` in the closure is stale | Functional update: `setCount(prev => prev + 1)` |
| `setData([...data, newItem])` in a `useEffect` where `data` is not in deps | Stale closure | Add `data` to deps, or use functional form |
| `items.push(newItem); setItems(items)` | Mutates state directly | `setItems(prev => [...prev, newItem])` |

**Scaffolder rule:** Never generate `setState(currentState + delta)`. Always generate functional updater form `setState(prev => ...)` when new state depends on previous value.

---

## CC-CS3 — Module-Level Mutable Singletons Must Be Concurrency-Safe

Module-level mutable state accessed from multiple request handlers must be protected.

| Runtime | Unsafe pattern | Safe pattern |
|---------|---------------|-------------|
| Node.js (TypeScript) | Bare `Map` at module level used as a cache | Use `lru-cache` with TTL — not a plain Map |
| Go | `var cache = map[string]T{}` at package level, written from goroutines | `var cache sync.Map` or `RWMutex`-protected map |
| Python (asyncio) | Module-level `dict` read-modify-written across `await` points | Use `asyncio.Lock` if modifying across await boundaries |
| .NET | Static mutable field on a service | Use `ConcurrentDictionary` or inject as scoped dependency |

**Scaffolder rule:** Never generate a bare `Map`/`dict`/`{}` at module level as a cache. Generate using `lru-cache` (Node), `sync.Map` (Go), or an injected cache service.

---

## CC-CS4 — Do Not Perform Multiple Async Reads That Assume Consistency

Reading two related values from async sources in separate calls assumes they are consistent — they may not be.

| Unsafe pattern | Why | Safe pattern |
|---------------|-----|-------------|
| `const user = await getUser(id); const org = await getOrg(user.orgId); if (user.active && org.active)` | Another process could deactivate `user` between reads | Single query joining both, or document and accept the TOCTOU window |
| `if (await cache.has(key)) { const val = await cache.get(key); use(val); }` | Cache entry may expire between `has` and `get` | `const val = await cache.get(key); if (val !== undefined) use(val)` — single atomic read |
| Go: two map reads without lock | Data race | Hold lock for both, or use single read `val, ok := m[key]` |

---

## CC-CS5 — Idempotency Keys for State-Mutating Operations

Operations that may be retried (network timeouts, queue redelivery) must be idempotent or protected by an idempotency key.

| Context | Unsafe pattern | Required pattern |
|---------|---------------|-----------------|
| Payment endpoint | `POST /payments` creates a charge every call | Accept `Idempotency-Key` header; check if charge already exists before creating |
| Queue consumer | Message handler creates a record on every delivery | Check if record exists with message ID before inserting; use upsert |
| Webhook handler | `POST /webhook` processes every delivery | Store event ID; skip if already seen |
| Background job | Job retried after failure re-runs the full operation | Mark steps as completed; resume from last successful step |

**Scaffolder rule:** Generated payment routes must include an idempotency key check. Generated queue consumers must include deduplication using the message ID. At MVP depth, add `// TODO: add idempotency key storage` if deferring.

---

## Severity

| Rule | Severity | Rationale |
|------|---------|-----------|
| CC-CS1 mutable loop variable capture | BLOCKER | All closures reference the same final value — silent logic error |
| CC-CS2 stale closure in React state | WARNING | Non-deterministic state updates under rapid interaction |
| CC-CS3 unprotected shared mutable state | WARNING | Safe in Node.js single-thread but data race in Go/.NET/Python threaded contexts |
| CC-CS4 non-atomic paired reads | WARNING | TOCTOU window — accept or mitigate with a single atomic query |
| CC-CS5 non-idempotent mutation | WARNING | Duplicate charges/records under retry — escalates to BLOCKER for payment operations |

CC-CS1 is a BLOCKER — all generated loops with closures or goroutines must bind the iteration variable correctly.
