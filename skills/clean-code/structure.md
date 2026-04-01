# Clean Code — Structure Rules

Rules CC-S1, CC-S2, CC-S3. Loaded by the implementer for service and route layers, and by the reviewer for Check 5 (architecture fitness).

---

## CC-S1: Function Length

### Trigger — implementer

After writing a function body, count its lines (excluding blank lines and closing brace). If the count meets or exceeds the threshold for the runtime, stop and decompose before writing the next function.

### Trigger — reviewer

Scan added lines for function/method definition patterns (see table below). Count lines from the opening brace/colon to the closing brace/dedent. Compare against the threshold table.

**Detection patterns by runtime:**

| Runtime | Function start pattern |
|---------|----------------------|
| TypeScript / JavaScript | `(async )?function \w+\(` or `const \w+ = (async )?\(` or arrow method |
| Python | `(async )?def \w+\(` |
| Go | `func (\(\w+ \*?\w+\) )?\w+\(` |
| .NET / C# | `(public\|private\|protected\|internal).*(async )?\w+ \w+\(` |
| Java | `(public\|private\|protected).*(void\|\w+) \w+\(` |
| Swift | `func \w+\(` |
| Kotlin | `fun \w+\(` |

### Constraint

A function that exceeds its threshold must be decomposed into smaller named functions, each doing one thing. The decomposed functions are named after their **purpose** (what they accomplish), not their step in the parent algorithm (`step1`, `phase2`, `doFirst` are invalid names).

### Runtime thresholds

| Runtime | Threshold | Rationale |
|---------|-----------|-----------|
| TypeScript / JavaScript | 30 lines | Arrow functions and first-class functions make extraction cheap |
| Python | 25 lines | Short functions align with PEP 8 spirit; async handlers benefit from brevity |
| Go | 40 lines | Explicit error handling (`if err != nil`) legitimately adds lines |
| .NET / C# | 35 lines | LINQ chains can be dense; class methods trend longer |
| Java / Spring | 40 lines | Annotation overhead and checked exceptions inflate line count |
| Swift | 30 lines | Expression-oriented language; long functions signal missing abstraction |
| Kotlin | 30 lines | Same as Swift |
| Ruby | 20 lines | Rails convention favours very short methods |

### Before / After

```python
# BEFORE — 48 lines, does too much
async def create_order(payload: CreateOrderRequest, db: AsyncSession) -> OrderResponse:
    # validate items
    for item in payload.items:
        product = await db.get(Product, item.product_id)
        if not product:
            raise HTTPException(404, f"Product {item.product_id} not found")
        if product.stock < item.quantity:
            raise HTTPException(422, "Insufficient stock")

    # calculate totals
    subtotal = sum(item.quantity * item.unit_price for item in payload.items)
    discount = subtotal * 0.1 if payload.discount_code == "SAVE10" else 0
    total = subtotal - discount + payload.shipping_cost

    # persist
    order = Order(user_id=payload.user_id, total=total, status="pending")
    db.add(order)
    for item in payload.items:
        db.add(OrderItem(order=order, **item.dict()))
    await db.commit()
    await db.refresh(order)
    return OrderResponse.from_orm(order)

# AFTER — parent is 8 lines; each extracted function has one job
async def create_order(payload: CreateOrderRequest, db: AsyncSession) -> OrderResponse:
    await validate_order_items(payload.items, db)
    total = calculate_order_total(payload)
    order = await persist_order(payload, total, db)
    return OrderResponse.from_orm(order)
```

---

## CC-S2: Single Responsibility

### Trigger — implementer

Before naming a function, verify the name is a single verb-noun pair that fits on one line without "and", "or", "also", or "then". If the name requires a conjunction, the function has multiple responsibilities.

Additional signal: if you are about to add a comment block inside a function that acts as a section divider (`# Step 1 — validate`, `// --- calculate ---`), each section should be its own function.

### Trigger — reviewer

Scan added function/method names for conjunctions: `And`, `Or`, `Also`, `Then`, `AndThen` (case-insensitive within the name, e.g. `validateAndSave`, `fetchAndProcess`).

Scan function bodies for section-divider comments: lines that are only a comment containing step/phase/section language (`# Phase 1`, `// --- auth check ---`, `/* STEP: */`).

### Constraint

Each function does exactly one thing, described by a verb-noun pair without conjunctions. Section-divider comments inside a function body indicate the sections should be extracted as named functions and called in sequence from the parent.

### Before / After

```typescript
// BEFORE — three responsibilities in one function
async function validateAndSaveAndNotifyUser(userId: string, data: UpdateProfileRequest) {
  // --- validate ---
  if (!data.email.includes('@')) throw new BadRequestError('Invalid email')
  const existing = await userRepo.findByEmail(data.email)
  if (existing && existing.id !== userId) throw new ConflictError('Email taken')

  // --- save ---
  const user = await userRepo.update(userId, data)

  // --- notify ---
  await emailService.sendProfileUpdatedEmail(user.email)
  return user
}

// AFTER — composed from three focused functions
async function updateUserProfile(userId: string, data: UpdateProfileRequest) {
  await validateProfileUpdate(userId, data)
  const user = await saveProfileUpdate(userId, data)
  await notifyProfileUpdated(user)
  return user
}
```

---

## CC-S3: Abstraction Levels

### Trigger — implementer

If a function contains both: (a) calls to other named domain functions (high-level orchestration) AND (b) direct loops, arithmetic, or field-level operations on data structures (low-level detail) — abstraction levels are mixed. Extract the low-level operations to a named function before continuing.

### Trigger — reviewer

Within a single added function body, detect both:
- A call to another named function (pattern: `await functionName(`, `service.method(`, `repo.find(`)
- A loop (`for`, `forEach`, `map`, `reduce`, `while`) OR arithmetic expression on a field (`item.price * item.quantity`, `total +=`, `sum(x.field for x in`)

Both present in the same function = mixed abstraction. Flag as SUGGEST.

### Constraint

A function operates at one abstraction level. Orchestration functions call named domain functions only. Computation functions perform the calculation only and are called by orchestrators. Do not mix levels in the same function body.

### Before / After

```typescript
// BEFORE — mixes orchestration (emailService call) with low-level arithmetic
async function processRefund(orderId: string): Promise<void> {
  const order = await orderRepo.findById(orderId)
  const refundAmount = order.items.reduce(
    (sum, item) => sum + item.price * item.quantity, 0
  ) * 0.9  // 10% restocking fee
  await paymentService.refund(order.paymentId, refundAmount)
  await emailService.sendRefundConfirmation(order.userId, refundAmount)
}

// AFTER — orchestration at one level, calculation extracted
async function processRefund(orderId: string): Promise<void> {
  const order = await orderRepo.findById(orderId)
  const refundAmount = calculateRefundAmount(order)
  await paymentService.refund(order.paymentId, refundAmount)
  await emailService.sendRefundConfirmation(order.userId, refundAmount)
}

function calculateRefundAmount(order: Order): number {
  const subtotal = order.items.reduce((sum, item) => sum + item.price * item.quantity, 0)
  return subtotal * 0.9
}
```
