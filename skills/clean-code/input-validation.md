# Input Validation at Boundaries

Rules CC-IV1 through CC-IV5. Apply at **write time** (scaffolder and implementer) for every route handler, IPC handler, and event consumer. Generated code must never trust external input without validating its shape, type, and constraints before use.

---

## CC-IV1 — Validate Request Body Before Accessing Fields

Every route handler that accepts a request body must validate it against a schema before accessing any field.

| Runtime / Framework | Unsafe pattern | Required pattern |
|--------------------|---------------|-----------------|
| TypeScript (Express) | `const { userId, amount } = req.body; await processPayment(userId, amount)` | `const body = PaymentSchema.parse(req.body); await processPayment(body.userId, body.amount)` |
| TypeScript (Fastify) | Route defined without `schema.body` | Add `schema: { body: PaymentBodySchema }` to route options |
| TypeScript (NestJS) | DTO class without `class-validator` decorators | Add `@IsString()`, `@IsNumber()` etc. and enable `ValidationPipe` globally |
| Python (FastAPI) | `async def create(body: dict)` | `async def create(body: PaymentRequest)` where `PaymentRequest` is a Pydantic `BaseModel` |
| Python (Flask) | `data = request.get_json(); user_id = data['userId']` | Validate with Pydantic or marshmallow before use |
| Go (Gin) | `c.BindJSON(&body)` without checking error | `if err := c.ShouldBindJSON(&body); err != nil { c.JSON(400, gin.H{"error": err.Error()}); return }` |
| .NET | Controller action without `ModelState.IsValid` check | Use `[ApiController]` (auto-validates) or check `ModelState.IsValid` |

**Scaffolder rule:** Every generated POST/PUT/PATCH route handler must have a schema parse as the first statement. Never generate a route that accesses `req.body.x` directly without parsing.

---

## CC-IV2 — Validate Path and Query Parameters

Path parameters and query string values arrive as raw strings. Validate type and format before use.

| Parameter type | Unsafe pattern | Required pattern |
|---------------|---------------|-----------------|
| Entity ID | `const id = req.params.id; await repo.findById(id)` | Validate format: UUIDs → `z.string().uuid()`, ObjectId → regex, numeric → `z.coerce.number().int().positive()` |
| Pagination | `req.query.page` / `req.query.limit` used in arithmetic | `z.coerce.number().int().min(1).default(1).parse(req.query.page)` |
| Enum filter | `req.query.status` passed directly to DB query | `StatusSchema.parse(req.query.status)` where `StatusSchema = z.enum([...])` |
| Date range | `new Date(req.query.from)` with no validity check | `z.coerce.date().parse(req.query.from)` — throws on invalid date |

**Scaffolder rule:** Generated route handlers must never pass `req.params.*` or `req.query.*` directly to a repository call. Coerce and validate first.

---

## CC-IV3 — Sanitise String Inputs Before Persistence or Rendering

| Concern | Unsafe pattern | Required pattern |
|---------|---------------|-----------------|
| Unbounded string length | `name: z.string()` | `name: z.string().trim().min(1).max(255)` |
| Whitespace-only values | `z.string().min(1)` — passes `"   "` | `z.string().trim().min(1)` |
| HTML in server-rendered output | `res.send('<div>' + userInput + '</div>')` | Use a templating engine that escapes by default |
| Numeric strings in computation | `parseInt(req.body.amount) * rate` with no NaN check | `z.coerce.number().positive().finite().parse(req.body.amount)` |

---

## CC-IV4 — Validate Environment Variables at Startup

Missing or malformed env vars should fail fast at process start, not at runtime under load.

| Runtime | Unsafe pattern | Required pattern |
|---------|---------------|-----------------|
| TypeScript | `process.env.PORT` used inline in routes | Define a config module with Zod: `const config = z.object({ PORT: z.coerce.number().default(3000), DATABASE_URL: z.string().url() }).parse(process.env)` |
| Python | `os.environ['DATABASE_URL']` inside a request handler | Use Pydantic `BaseSettings` — instantiate once at module load |
| Go | `os.Getenv("DATABASE_URL")` inline | Parse all required env vars in `main()` before starting the server; `log.Fatal` if any are missing |
| .NET | `Configuration["ConnectionStrings:Default"]` without null check | Use strongly-typed `IOptions<T>` with `[Required]` and `ValidateOnStart()` |

**Scaffolder rule:** Generated projects must always include a config module that validates all env vars at startup. Never generate inline `process.env.X` reads in service or route files.

---

## CC-IV5 — Reject Unknown Fields — Do Not Silently Pass Them Through

Schema validation must strip or reject unexpected fields. Passing unknown fields through to an ORM is a mass-assignment vector.

| Runtime | Unsafe pattern | Required pattern |
|---------|---------------|-----------------|
| TypeScript (Zod) | `.passthrough()` on user input schemas | Default `.strip()` or `.strict()` — never `.passthrough()` on request schemas |
| Python (Pydantic v2) | `model_config = ConfigDict(extra='allow')` on a request model | `model_config = ConfigDict(extra='forbid')` |
| Python (Pydantic v1) | `class Config: extra = 'allow'` | `class Config: extra = 'forbid'` |
| Go | `json.Unmarshal` ignores unknown fields by default | `dec := json.NewDecoder(r.Body); dec.DisallowUnknownFields(); dec.Decode(&req)` |
| .NET | Default model binding passes through unknown properties | Configure `JsonUnmappedMemberHandling.Disallow` |

---

## Severity

| Rule | Severity | Rationale |
|------|---------|-----------|
| CC-IV1 unvalidated request body | BLOCKER | Type confusion, panics, or injection when unvalidated fields reach DB or business logic |
| CC-IV2 unvalidated path/query params | BLOCKER | Type coercion failures, invalid DB queries, injection via malformed IDs |
| CC-IV3 unsanitised string inputs | WARNING | Length violations cause DB errors; unsanitised HTML is XSS |
| CC-IV4 unvalidated env vars | WARNING | Config errors surface at runtime, not at startup |
| CC-IV5 unknown fields passed through | WARNING | Mass-assignment risk — escalates to BLOCKER if ORM binds the full body |

CC-IV1 and CC-IV2 are BLOCKERs — unvalidated input reaching persistence or business logic is an immediate correctness and security failure.
