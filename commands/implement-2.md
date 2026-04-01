# /architect:implement — Steps 5–9

_Part 2 of 2. Read implement-index.md and implement-1.md first._

---

## Step 5: Write the Files

Write in dependency order: **schema/validation → model/migration → service → route/controller → integration lib → test → frontend**.

### 5a. General rules for every file written

- Match the `pattern_fingerprint` exactly — same import style, error format, naming convention, validation library, ORM patterns.
- For **NEW files**: write the complete file with real, working logic. No TODOs, no empty function bodies, no placeholder comments.
- For **MOD files**: read the full existing file first, then insert at the identified location. Never delete existing code. Preserve existing comments, formatting, and blank line style.
- Apply production hardening on all new backend files — read the correct runtime sub-file:
  - Node.js / TypeScript: `skills/production-hardening/SKILL.md`
  - Python: `skills/production-hardening/python.md`
  - Go: `skills/production-hardening/go.md`
  - .NET: `skills/production-hardening/dotnet.md`
  - Other runtimes: use the patterns from SKILL.md as a reference and apply the runtime-equivalent library
- Use the existing custom error classes found in the codebase — grep for them rather than inventing new ones.
- Never use `console.log`, `print()`, or equivalent for structured logging — use the logger already present in the codebase.

### 5b. Schema / Validation layer

Create or update the validation schema file for the feature's request and response shapes. Use the library detected in `pattern_fingerprint.validation`:

| Runtime / Library | File location | Pattern |
|---|---|---|
| TypeScript + zod | `src/schemas/<resource>.<ext>` | `z.object({...}).strict()` + inferred type exports |
| TypeScript + class-validator (NestJS) | `src/dto/<Resource>Dto.<ext>` | DTO class with decorators + `@ApiProperty()` |
| Python + Pydantic | `app/schemas/<resource>.py` | `class CreateXRequest(BaseModel)` + `class XResponse(BaseModel)` |
| Go + go-playground/validator | `internal/<resource>/dto.go` | struct with `validate:"..."` tags |
| .NET + FluentValidation | `Application/<Resource>/Commands/Create<Resource>CommandValidator.cs` | `RuleFor(x => x.Field).NotEmpty()` |
| Java + Bean Validation | `src/main/java/.../dto/<Resource>Request.java` | annotations `@NotNull`, `@Size`, `@Email` |

Export both request and response types/structs. The route layer imports from here — never defines inline validation.

### 5c. Model / Migration layer

If the feature requires a new or modified data entity:

1. **Update the ORM model/entity** — add fields using the ORM convention detected in `pattern_fingerprint.orm`:
   - Prisma: update `schema.prisma`, add model or fields
   - SQLAlchemy: update `app/models/<entity>.py`, add Column definitions
   - GORM: update `internal/<entity>/model.go`, add struct fields
   - EF Core: update entity class and `DbContext`, add migration
   - Spring Data JPA: update `@Entity` class, add fields with `@Column`
   - Drizzle: update `src/db/schema.ts`, add table columns

2. **Write a migration stub** — produce the file, do not run it:

| Tool | Migration file location | Format |
|---|---|---|
| Prisma | `prisma/migrations/<timestamp>_<feature_slug>/migration.sql` | Raw SQL `ALTER TABLE` / `CREATE TABLE` |
| Alembic | `alembic/versions/<revision>_<feature_slug>.py` | `def upgrade()` / `def downgrade()` |
| golang-migrate | `migrations/<timestamp>_<feature_slug>.up.sql` + `.down.sql` | Raw SQL |
| EF Core | `Migrations/<Timestamp>_<FeatureSlug>.cs` | Generated class with `Up()` / `Down()` |
| Flyway / Liquibase | `src/main/resources/db/migration/V<N>__<feature_slug>.sql` | Raw SQL |
| Django | `<app>/migrations/<N>_<feature_slug>.py` | Auto-generated via `makemigrations` pattern |

Add a comment at the top of each migration file:
```sql
-- Run before testing: <runtime-appropriate migration command>
-- Rollback: <runtime-appropriate rollback command>
```

### 5d. Service layer

Write one function/method per acceptance criterion requiring business logic. Use the naming and structure convention from the fingerprint:

| Style | Pattern |
|---|---|
| Exported functions (functional) | `export async function createNotification(payload: CreateNotificationPayload): Promise<Notification>` |
| Class-based (NestJS, Spring, .NET) | Method on `@Injectable()` service / `@Service` bean / `INotificationService` implementation |
| Python functions | `async def create_notification(payload: CreateNotificationRequest, db: AsyncSession) -> NotificationResponse:` |
| Go functions | `func (s *NotificationService) Create(ctx context.Context, req CreateNotificationRequest) (*Notification, error)` |

Rules:
- Call the data access layer (ORM/repository) — no raw queries in the service layer unless the project uses raw queries throughout.
- Throw/return the same error types used in existing services (detected by grep).
- If calling an external service (email, payment, SMS): isolate in a `lib/` or `integrations/` wrapper, call from service — not inline.

### 5e. Route / Controller layer

Wire the service to an HTTP handler matching the route style in the fingerprint:

| Style | Registration pattern |
|---|---|
| Express router | `router.post('/path', validate(schema), authMiddleware, handler)` — register in `routes/index.*` |
| Fastify plugin | `fastify.post('/path', { schema: { body: schema } }, handler)` — register in `app.*` |
| NestJS controller | `@Post('/path')` method on `@Controller` class — module wiring in `*.module.ts` |
| FastAPI router | `@router.post('/path', response_model=XResponse)` — include router in `main.py` or `app/__init__.py` |
| Go Gin/Echo/Chi | `r.POST('/path', middleware.Auth(), handler)` — register in router setup |
| .NET controller | `[HttpPost]` action on `[ApiController]` class — no manual registration needed |
| Spring MVC | `@PostMapping('/path')` on `@RestController` class — no manual registration needed |

Always:
- Apply the auth middleware/guard/decorator if the SDL requires auth for this resource
- Apply input validation before the handler runs
- Return errors in the format matching `pattern_fingerprint.error_format`
- MOD the route registration file to mount any new router/controller

### 5f. Integration lib (when feature calls an external service)

Create `lib/<provider>.<ext>` or `integrations/<provider>/<provider>.<ext>` (match what exists):
- Wrap the external SDK in a thin function with typed inputs/outputs
- Read credentials from environment — never hardcode
- Add the new env var key (not value) to `<component>/.env.example` with a comment explaining where to get it
- Apply retry + timeout using the runtime-appropriate library (Pattern 7 from production-hardening skill)

### 5g. Test layer

Write a minimum of 4 tests using the runner and file location from the fingerprint:

| Test | What to cover |
|---|---|
| Happy path | Feature works end-to-end with valid input |
| Validation failure | Invalid input returns the correct error code and format |
| Not found / empty | Resource doesn't exist returns appropriate response |
| Edge case | One AC-specific scenario (e.g. duplicate, concurrent call, auth failure) |

Mock external dependencies using the same strategy found in existing tests:

| Runtime | Mock pattern |
|---|---|
| TypeScript (vitest/jest) | `vi.mock(...)` / `jest.mock(...)` |
| Python (pytest) | `unittest.mock.patch` / `pytest-mock` `mocker.patch` |
| Go | Interface-based mocks (match what exists — `mockery`, `testify/mock`, or hand-rolled) |
| .NET | `NSubstitute` / `Moq` (match what existing tests use) |
| Java | `Mockito.when(...)` |

Tests must pass with the code written in this step. No skipped or pending tests.

---

## Step 6: Multi-Component Wiring

When the write plan touches more than one component:

**Frontend API client update:**
Read the existing API client file (detected from fingerprint — `src/lib/api.*`, `src/services/api.*`, etc.). Add one typed function per new backend endpoint. Match the existing call style exactly (axios instance, fetch wrapper, typed return, error handling pattern).

**i18n updates (frontend):**
If i18n files exist (`src/i18n/locales/en.json` or equivalent), add new keys for every new user-facing string. Update `en.json`, `es.json`, and `ar.json` in the same commit. Never hardcode user-facing strings in component files.

**Shared types package:**
If a shared-lib component exists in `_state.json.components[]`, add new request/response interfaces there instead of duplicating across components. If no shared package exists, add a `// sync-candidate` comment on the duplicated types.

**Environment variables:**
For each new env var introduced by the feature, add it to `<component>/.env.example` with a descriptive comment. Add key only — no value. Do not add env vars that already exist in the file.

**Cross-component ordering:**
Always write and verify backend files before frontend files. Write migration stubs before the service that depends on them.

---

## Step 7: Build Verification

**Mandatory. Do not skip.**

For each affected component, run in order:

| Step | Command by runtime |
|------|--------------------|
| **Install** (only if new deps added) | Node.js: `npm install` · Python: `pip install -e .` · Go: `go mod tidy` · .NET: `dotnet restore` · Java: `mvn dependency:resolve -q` · Flutter: `flutter pub get` · Ruby: `bundle install` |
| **Build / compile** | Node.js/TS: `npx tsc --noEmit` · Next.js: `npx tsc --noEmit` · Python: `python -m py_compile $(find . -name "*.py" -not -path "*/.venv/*")` · Go: `go build ./...` · .NET: `dotnet build --no-restore` · Java: `mvn compile -q` · Swift: `xcodebuild build -scheme {{name}} CODE_SIGNING_REQUIRED=NO` · Kotlin: `./gradlew compileDebugKotlin` |
| **Test** | Node.js: `npm test` · Python: `pytest` · Go: `go test ./...` · .NET: `dotnet test --no-build` · Java: `mvn test -q` |
| **Lint** | Node.js/TS: `npm run lint` (if script exists) · Python: `ruff check .` · Go: `golangci-lint run ./...` · Java: `mvn checkstyle:check -q` |

**On failure:**
- Read every error message.
- Fix the source file — never add language-specific suppression comments (`// @ts-ignore`, `# noqa`, `//nolint`, `@SuppressWarnings`) to hide errors. Fix them properly.
- Re-run the failing step.
- Maximum 3 fix cycles per error. If unresolved after 3, add a `KNOWN_ISSUES` comment block at the top of the affected file.

**Scope:** verification covers only files written by this command. Pre-existing failures are reported to the user but not fixed.

---

## Step 8: Print Summary

```
Implemented: <story_title> (<story_id>)

Files written:
  <component>/                     [<runtime> / <framework>]
    NEW  <relative-path>           — <one-line purpose>
    MOD  <relative-path>           — <what changed, e.g. "+3 lines: register router">
  <frontend-component>/
    MOD  <relative-path>           — <what changed>

Verification:
  <component>   — build ✓ | tests 4/4 ✓ | lint ✓
  <frontend>    — build ✓ | tests 2/2 ✓

Manual steps required:
  1. Run migrations: <runtime-appropriate migration command>
  2. Add <ENV_VAR_NAME> to your .env file — get it from <source>
```

If any verification step failed and could not be fixed, list the remaining errors under a `Build issues` section.

---

## Step 9: Log Activity

**Project-level** — append to `architecture-output/_activity.jsonl`:

```json
{"ts":"<ISO-8601>","phase":"implement","story":"<story_id>","feature":"<feature_slug>","outcome":"completed|partial","components":["<name>"],"files_new":["<component>/path"],"files_modified":["<component>/path"],"summary":"Implemented <story_title>. <N> new files, <M> modified. Build and tests pass."}
```

**Component-level** — append to `<component>/_activity.jsonl` for each affected component:

```json
{"ts":"<ISO-8601>","phase":"implement","story":"<story_id>","feature":"<feature_slug>","outcome":"completed|partial","files_new":["path"],"files_modified":["path"],"summary":"<story_title> — <N> new files, <M> modified. Build and tests pass."}
```

Rules: append only — never overwrite. Single JSON object per line, no pretty-printing.

If the feature introduced a new entity, also update `architecture-output/_state.json` — append to `entities[]`:

```json
{"name": "NotificationLog", "fields": ["id", "orderId", "sentAt", "status"], "owner": "<component>"}
```

---

## Output Rules

- Generate REAL code matching the codebase's existing patterns — not stubs, not placeholder comments.
- Never default to Node.js/TypeScript patterns when the fingerprint says otherwise.
- When reading `architecture-output/data-model.md`, use Grep to extract only the relevant entity — do not read the entire file.
- Do NOT include a CTA footer.
- If multi-component: delegate each component to the `implementer` agent (`agents/implementer.md`) so failures are isolated. Pass the `pattern_fingerprint`, `write_plan`, `story` context, and `sdl_context` for that component.
