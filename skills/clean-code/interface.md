# Clean Code — Interface Design Rules

Rules CC-I1, CC-I2. Loaded by the implementer for service and route layers. Referenced by the reviewer in Check 1 (pattern conformance).

---

## CC-I1: Parameter Count

### Trigger — implementer

Before writing a function body, count its parameters. If the count meets or exceeds the threshold for the runtime, stop and apply the **parameter object pattern** before writing the body. Do not write a long parameter list and intend to refactor later — design the signature first.

### Trigger — reviewer

Scan added function/method definitions for parameter count. Count only top-level parameters — destructured properties inside a single object parameter do not count toward the limit (that is already the parameter object pattern applied correctly).

**Do not count:**
- `self` / `this` implicit receiver parameters (Python, Go struct receivers)
- Framework-injected parameters that the developer has no control over (e.g., `HttpContext` in .NET middleware, `Context` in Go handlers passed by the framework)

### Constraint

When parameter count exceeds the threshold: group logically related parameters into a single typed object. The object's type name must describe what it represents. Avoid generic names: `Options`, `Params`, `Args`, `Data` are acceptable only if the function name already provides the domain context (e.g. `CreateOrderOptions` is fine for `createOrder`).

If parameters are not logically related and cannot be grouped, the function likely has multiple responsibilities — apply CC-S2 first.

### Runtime thresholds

| Runtime | Threshold | Parameter object syntax |
|---------|-----------|------------------------|
| TypeScript | 3 | `interface CreateOrderRequest { ... }` — pass as single typed param |
| JavaScript | 3 | Destructured object: `function create({ userId, items, discount })` |
| Python | 4 | `@dataclass class CreateOrderRequest` or Pydantic `BaseModel` |
| Go | 4 | Struct: `type CreateOrderRequest struct { ... }` passed by value or pointer |
| .NET / C# | 3 | `record CreateOrderRequest(string UserId, ...)` or class with init properties |
| Java | 3 | Builder pattern or `record CreateOrderRequest(String userId, ...)` |
| Swift | 4 | Struct with labeled arguments (Swift argument labels partially mitigate confusion at call sites) |
| Kotlin | 4 | Data class: `data class CreateOrderRequest(val userId: String, ...)` |
| Ruby | 3 | Keyword arguments hash or Struct |

### Before / After

```typescript
// BEFORE — 6 parameters, call site is unreadable
async function createOrder(
  userId: string,
  items: OrderItem[],
  discountCode: string | null,
  shippingAddress: Address,
  paymentMethodId: string,
  sendConfirmationEmail: boolean
): Promise<Order> { ... }

// Called as:
await createOrder(userId, items, null, address, paymentId, true)
// What does `null` mean? What does `true` mean? Unreadable.

// AFTER — single typed request object
interface CreateOrderRequest {
  userId: string
  items: OrderItem[]
  discountCode?: string
  shippingAddress: Address
  paymentMethodId: string
  sendConfirmationEmail: boolean
}

async function createOrder(request: CreateOrderRequest): Promise<Order> { ... }

// Called as:
await createOrder({ userId, items, shippingAddress: address, paymentMethodId, sendConfirmationEmail: true })
// Intent is clear at the call site.
```

---

## CC-I2: Boolean Trap

### Trigger — implementer

Never pass a boolean literal (`true` / `false`) as an argument to a function unless the parameter is the **only** argument and the function name makes the boolean's meaning self-evident. If there is any ambiguity at the call site, apply the constraint before writing.

### Trigger — reviewer

Scan added function call expressions for boolean literal arguments (`true`, `false`, `True`, `False`). Flag any call where:
- The boolean is not the only argument, OR
- The function name does not make the boolean's meaning obvious without reading the function signature

**Exceptions — do NOT flag:**
- `Promise.resolve(true)` / `Promise.reject(false)` — the boolean is the value, not a mode switch
- `setIsLoading(true)` / `setIsVisible(false)` — state setter where the boolean is the state value, not a mode
- `assert(result === true)` — test assertion
- Framework lifecycle calls where boolean flags are idiomatic: `useEffect(..., [])`, `res.json({ success: true })`

### Constraint

Replace boolean mode parameters with one of:
1. **Two separate well-named functions** — one for each mode (preferred when the modes are fundamentally different behaviours)
2. **An enum or string constant** — names the mode explicitly at both the definition and call site
3. **A named options object** — the boolean key name makes intent clear at the call site

### Runtime-specific enum/constant patterns

| Runtime | Preferred pattern |
|---------|-----------------|
| TypeScript | `type DeliveryMode = 'sync' \| 'async'` or `enum DeliveryMode { Sync = 'sync', Async = 'async' }` |
| Python | `from enum import Enum; class DeliveryMode(Enum): SYNC = 'sync'; ASYNC = 'async'` or `Literal['sync', 'async']` |
| Go | `type DeliveryMode string; const (DeliverySync DeliveryMode = "sync"; DeliveryAsync DeliveryMode = "async")` |
| .NET / C# | `enum DeliveryMode { Sync, Async }` |
| Java | `enum DeliveryMode { SYNC, ASYNC }` |
| Swift | `enum DeliveryMode { case sync, async_ }` |
| Kotlin | `enum class DeliveryMode { SYNC, ASYNC }` |

### Before / After

```python
# BEFORE — what does True mean at the call site?
await send_notification(user_id, message, True)

def send_notification(user_id: str, message: str, urgent: bool) -> None:
    if urgent:
        await sms_service.send(user_id, message)
    else:
        await email_service.send(user_id, message)

# AFTER — option A: two functions (behaviours are meaningfully different)
await send_urgent_notification(user_id, message)   # clear intent
await send_notification(user_id, message)           # clear intent

# AFTER — option B: enum (behaviours share logic, mode selects channel)
class NotificationChannel(Enum):
    SMS = "sms"
    EMAIL = "email"

await send_notification(user_id, message, channel=NotificationChannel.SMS)
```
