# Async Safety

Rules CC-AS1 through CC-AS5. Apply at **write time** (scaffolder and implementer) and **review time** (reviewer Check 1 and Check 2). These are generation constraints — generated code must never contain an unawaited promise, a floating async call, or swallowed async errors.

---

## CC-AS1 — Every Promise Must Be Awaited or Explicitly Handled

A `Promise` returned by an `async` function must either be `await`-ed, returned to the caller, or handled with `.then()/.catch()`. Unhandled floating promises are silent failures.

| Runtime | Unsafe pattern | Safe pattern |
|---------|---------------|-------------|
| TypeScript/JavaScript | `doSomething();` where `doSomething` returns `Promise<void>` — no `await` | `await doSomething();` |
| TypeScript/JavaScript | `array.forEach(async (item) => { await process(item); })` — forEach does not await returned promises | `for (const item of array) { await process(item); }` or `await Promise.all(array.map(async (item) => process(item)))` |
| Python | `asyncio.create_task(fn())` with no reference kept and no `await` | Keep the task: `task = asyncio.create_task(fn()); await task` or cancel in cleanup |
| Go | `go func() { if err := doWork(); err != nil { /* dropped */ } }()` | Channel the error back: `errCh <- err` or log it |

**Scaffolder rule:** Never generate `array.forEach(async ...)`. Always use `for...of` with `await` for sequential, or `Promise.all(array.map(...))` for parallel. Never generate a floating async call without `await`.

---

## CC-AS2 — Do Not Mix async/await With Raw .then() Chains in the Same Function

Mixing `await` and `.then()` in the same function body creates confusing control flow and inconsistent error handling.

| Unsafe pattern | Safe pattern |
|---------------|-------------|
| `const data = await fetch(url); data.json().then(body => process(body))` | `const data = await fetch(url); const body = await data.json(); process(body);` |
| `return getUserAsync().then(user => { const org = await getOrg(user.orgId); ... })` | Rewrite entirely with `async/await` |

**Exception:** `.catch()` appended to a fully `await`-ed expression is acceptable: `await fn().catch(handleError)`.

---

## CC-AS3 — Async Functions Must Propagate Errors — Not Swallow Them

An `async` function must not have a bare `try/catch` that catches all errors and returns a default value without signalling failure.

| Unsafe pattern | Why | Safe pattern |
|---------------|-----|-------------|
| `async function getUser(id) { try { return await repo.get(id); } catch { return null; } }` | Caller cannot distinguish "not found" from "DB is down" | Catch only specific errors; rethrow unexpected errors |
| `async function sendEmail() { try { await mailer.send(...); } catch (e) { console.log(e); } }` | Error logged but caller thinks it succeeded | `throw` after logging, or return a typed result |
| Python: `async def fetch_data(): try: return await client.get(...) except Exception: return None` | Same | `except SpecificError: return None` / `except Exception: raise` |

---

## CC-AS4 — Do Not Create Async Race Conditions via Parallel State Mutation

Launching multiple async operations in parallel that each write to the same mutable variable creates non-deterministic state.

| Unsafe pattern | Safe pattern |
|---------------|-------------|
| `let result = []; await Promise.all(items.map(async item => { result.push(await process(item)); }))` | `const result = await Promise.all(items.map(item => process(item)))` — collect return values |
| Python: `asyncio.gather` with tasks mutating a shared list | Return values from tasks: `results = await asyncio.gather(*[fetch(url) for url in urls])` |
| Go: multiple goroutines writing to a shared slice without a mutex | Use a channel or `sync.Mutex` |

---

## CC-AS5 — Set Timeouts on All External Async Calls

An async call to an external system with no timeout will hang indefinitely. Every generated external call must have a timeout.

| Runtime | Timeout pattern |
|---------|----------------|
| TypeScript (fetch) | `const controller = new AbortController(); setTimeout(() => controller.abort(), 10_000); await fetch(url, { signal: controller.signal })` |
| TypeScript (axios) | `axios.get(url, { timeout: 10_000 })` |
| Python (httpx) | `async with httpx.AsyncClient(timeout=10.0) as client: await client.get(url)` |
| Go | `ctx, cancel := context.WithTimeout(ctx, 10*time.Second); defer cancel()` |
| .NET | `httpClient.Timeout = TimeSpan.FromSeconds(10);` |

**Scaffolder rule:** Every generated HTTP client helper or DB call wrapper must include a timeout. MVP → 10s constant with `// TODO: make configurable`; Growth/Enterprise → env var configurable.

---

## Severity

| Rule | Severity | Rationale |
|------|---------|-----------|
| CC-AS1 unawaited promise | BLOCKER | Silent failure — errors swallowed and operations silently skip |
| CC-AS2 mixed async styles | WARNING | Confusing control flow and inconsistent error propagation |
| CC-AS3 async error swallowed | BLOCKER | Caller cannot detect failure — same production impact as CR-E1 |
| CC-AS4 parallel state mutation | WARNING | Non-deterministic results; data races in non-JS runtimes |
| CC-AS5 no timeout on external call | WARNING | Hangs indefinitely under network partition or slow dependency |

CC-AS1 and CC-AS3 are BLOCKERs — they cause silent failures indistinguishable from success at the call site.
