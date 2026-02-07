# E-commerce/Marketplace Architecture Depth

## Payment Flow & Idempotency

### Stripe Integration with Idempotency Keys

**Critical**: Never charge customer twice for same order

```typescript
app.post('/checkout', async (req, res) => {
  const { cartId } = req.body

  // Generate idempotency key from cart ID
  const idempotencyKey = `checkout_${cartId}_${Date.now()}`

  try {
    const paymentIntent = await stripe.paymentIntents.create({
      amount: totalAmount,
      currency: 'usd',
      customer: stripeCustomerId,
      metadata: { order_id: orderId }
    }, {
      idempotencyKey  // ⚠️ CRITICAL: Prevents duplicate charges
    })

    res.json({ clientSecret: paymentIntent.client_secret })
  } catch (err) {
    // If same idempotency key sent twice, Stripe returns original response
    // No duplicate charge created
  }
})
```

**Why Idempotency Matters**:
- User clicks "Pay" twice (impatient)
- Network timeout causes retry
- Without idempotency: Customer charged twice ❌
- With idempotency: Second request returns original result ✅

---

### Webhook Handling for Payment Confirmation

**Stripe Webhooks are the source of truth** (not client-side confirmation)

```typescript
app.post('/webhooks/stripe', async (req, res) => {
  const sig = req.headers['stripe-signature']
  const event = stripe.webhooks.constructEvent(req.body, sig, webhookSecret)

  if (event.type === 'payment_intent.succeeded') {
    const paymentIntent = event.data.object
    const orderId = paymentIntent.metadata.order_id

    // Mark order as paid
    await db.query(
      'UPDATE orders SET status = $1, paid_at = NOW() WHERE id = $2',
      ['paid', orderId]
    )

    // Trigger fulfillment
    await queue.add('fulfill-order', { orderId })
  }

  if (event.type === 'payment_intent.payment_failed') {
    // Cancel order, notify customer
    await db.query('UPDATE orders SET status = $1 WHERE id = $2', ['failed', orderId])
    await sendEmail(customer.email, 'Payment failed')
  }

  res.json({ received: true })
})
```

**Security**: Verify webhook signature to prevent spoofing

---

## Inventory Management

### Race Condition Prevention

**Problem**: Two users buy last item simultaneously

**Solution 1: Database Transaction with Row Locking** (Recommended)
```sql
BEGIN;

-- Lock row for update
SELECT stock FROM products WHERE id = $1 FOR UPDATE;

-- Check if enough stock
IF stock >= quantity THEN
  UPDATE products SET stock = stock - quantity WHERE id = $1;
  INSERT INTO order_items (order_id, product_id, quantity) VALUES (...);
  COMMIT;
ELSE
  ROLLBACK;
  -- Return "Out of stock"
END IF;
```

**Solution 2: Optimistic Locking with Version Number**
```sql
-- Add version column
ALTER TABLE products ADD COLUMN version INT NOT NULL DEFAULT 1;

-- Update only if version matches
UPDATE products
SET stock = stock - $1, version = version + 1
WHERE id = $2 AND version = $3 AND stock >= $1;

-- If rowCount = 0, version changed (someone else updated) → retry
```

**Solution 3: Redis Atomic Decrement** (For high-traffic)
```typescript
const newStock = await redis.decrby(`stock:${productId}`, quantity)

if (newStock < 0) {
  // Out of stock, rollback
  await redis.incrby(`stock:${productId}`, quantity)
  throw new Error('Out of stock')
}

// Reserve stock in Redis, persist to DB asynchronously
await db.query('UPDATE products SET stock = stock - $1 WHERE id = $2', [quantity, productId])
```

**Recommendation**: Solution 1 for <1K orders/day, Solution 3 for high-traffic

---

### Stock Reservation

**Reserve stock during checkout (before payment)**:
```sql
CREATE TABLE stock_reservations (
  id UUID PRIMARY KEY,
  product_id UUID NOT NULL,
  quantity INT NOT NULL,
  user_id UUID NOT NULL,
  expires_at TIMESTAMPTZ NOT NULL,  -- 15 minutes
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Reserve stock
INSERT INTO stock_reservations (id, product_id, quantity, user_id, expires_at)
VALUES ($1, $2, $3, $4, NOW() + INTERVAL '15 minutes');

UPDATE products SET available_stock = available_stock - $1 WHERE id = $2;
```

**Cleanup Expired Reservations** (cron job every minute):
```typescript
cron.schedule('* * * * *', async () => {
  const expired = await db.query(
    'DELETE FROM stock_reservations WHERE expires_at < NOW() RETURNING *'
  )

  for (const reservation of expired) {
    // Release stock
    await db.query(
      'UPDATE products SET available_stock = available_stock + $1 WHERE id = $2',
      [reservation.quantity, reservation.product_id]
    )
  }
})
```

---

## Order State Machine

### Order Status Flow

```
cart
  ↓
pending (checkout started)
  ↓
awaiting_payment (payment initiated)
  ↓
paid (payment confirmed via webhook)
  ↓
processing (preparing shipment)
  ↓
shipped (tracking number assigned)
  ↓
delivered (tracking shows delivered)
  ↓
completed (customer confirmed or 14 days after delivery)

Side paths:
- failed (payment failed)
- cancelled (user or admin cancelled)
- refunded (refund issued)
```

**Database Schema**:
```sql
CREATE TABLE orders (
  id UUID PRIMARY KEY,
  user_id UUID NOT NULL,
  status TEXT NOT NULL CHECK (status IN ('cart', 'pending', 'awaiting_payment', 'paid', 'processing', 'shipped', 'delivered', 'completed', 'failed', 'cancelled', 'refunded')),
  total_amount INT NOT NULL,  -- cents
  stripe_payment_intent_id TEXT,
  shipping_address JSONB NOT NULL,
  tracking_number TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  paid_at TIMESTAMPTZ,
  shipped_at TIMESTAMPTZ,
  delivered_at TIMESTAMPTZ
);

CREATE TABLE order_status_history (
  id UUID PRIMARY KEY,
  order_id UUID NOT NULL,
  from_status TEXT NOT NULL,
  to_status TEXT NOT NULL,
  changed_by UUID,  -- user_id or admin_id
  reason TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);
```

**Status Transition Logic**:
```typescript
async function updateOrderStatus(orderId: string, newStatus: string, reason?: string) {
  const order = await db.query('SELECT * FROM orders WHERE id = $1', [orderId])

  // Validate transition
  const allowedTransitions = {
    'cart': ['pending'],
    'pending': ['awaiting_payment', 'cancelled'],
    'awaiting_payment': ['paid', 'failed', 'cancelled'],
    'paid': ['processing', 'refunded'],
    'processing': ['shipped', 'cancelled', 'refunded'],
    'shipped': ['delivered', 'refunded'],
    'delivered': ['completed', 'refunded']
  }

  if (!allowedTransitions[order.status]?.includes(newStatus)) {
    throw new Error(`Cannot transition from ${order.status} to ${newStatus}`)
  }

  // Update status
  await db.query('UPDATE orders SET status = $1 WHERE id = $2', [newStatus, orderId])

  // Log history
  await db.query(
    'INSERT INTO order_status_history (order_id, from_status, to_status, reason) VALUES ($1, $2, $3, $4)',
    [orderId, order.status, newStatus, reason]
  )

  // Trigger side effects
  if (newStatus === 'shipped') {
    await sendEmail(order.user_email, 'Your order has shipped', { trackingNumber: order.tracking_number })
  }
}
```

---

## Tax & Compliance

### Sales Tax Calculation (US)

**Use Stripe Tax** (Recommended):
```typescript
const paymentIntent = await stripe.paymentIntents.create({
  amount: subtotal,
  currency: 'usd',
  automatic_tax: { enabled: true },  // Stripe calculates tax automatically
  shipping: {
    name: customer.name,
    address: {
      line1: address.line1,
      city: address.city,
      state: address.state,
      postal_code: address.postal_code,
      country: 'US'
    }
  }
})

// Stripe returns total with tax included
const total = paymentIntent.amount + paymentIntent.tax
```

**Cost**: Stripe Tax = 0.5% of transaction + $10/month
**Why**: Handles nexus rules (which states you owe tax in), rate changes, filing

**Alternative: TaxJar API**
- Cost: $99/month + $0.002 per calculation
- More detailed reporting

---

### VAT (Europe)

**VAT Handling**:
```typescript
// Check if customer is in EU
const isEU = ['DE', 'FR', 'IT', 'ES', ...].includes(customerCountry)

if (isEU) {
  if (customer.vat_number) {
    // B2B: Reverse charge (no VAT charged, customer self-accounts)
    const vatRate = 0
  } else {
    // B2C: Charge VAT at customer's country rate
    const vatRate = vatRates[customerCountry]  // e.g., 19% for Germany
  }
}

const total = subtotal * (1 + vatRate)
```

**VAT Number Validation**:
```typescript
import { checkVAT } from 'jsvat'

const result = checkVAT(vatNumber, ['DE'])
if (!result.isValid) {
  throw new Error('Invalid VAT number')
}
```

---

## Shopping Cart Persistence

### Database vs Session Storage

**Option 1: Database Cart** (Recommended for logged-in users)
```sql
CREATE TABLE carts (
  id UUID PRIMARY KEY,
  user_id UUID UNIQUE NOT NULL,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE cart_items (
  id UUID PRIMARY KEY,
  cart_id UUID NOT NULL,
  product_id UUID NOT NULL,
  quantity INT NOT NULL CHECK (quantity > 0),
  added_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  UNIQUE (cart_id, product_id)
);
```

**Pros**:
- ✅ Cart persists across devices
- ✅ Can send "abandoned cart" emails
- ✅ Analytics on cart behavior

**Cons**:
- ❌ DB writes on every cart change

**Option 2: Session/Cookie Cart** (For anonymous users)
```typescript
// Store in encrypted cookie
res.cookie('cart', JSON.stringify(cart), {
  httpOnly: true,
  secure: true,
  maxAge: 7 * 24 * 60 * 60 * 1000  // 7 days
})
```

**Pros**:
- ✅ No DB load
- ✅ Fast

**Cons**:
- ❌ Lost if cookies cleared
- ❌ Not synced across devices

**Hybrid Approach**:
- Anonymous: Session cart
- On login: Merge session cart into DB cart

---

## Product Search & Filtering

### Elasticsearch for Product Search

**Why Elasticsearch**:
- Full-text search ("red nike shoes")
- Faceted filtering (brand, size, price range)
- Fuzzy matching ("addidas" → "adidas")
- Fast for 1M+ products

**Architecture**:
```
PostgreSQL (source of truth)
  ↓ (sync on product update)
Elasticsearch (search index)
  ↓ (user searches)
Frontend
```

**Sync Products to Elasticsearch**:
```typescript
app.post('/admin/products', async (req, res) => {
  const product = await db.query('INSERT INTO products (...) RETURNING *')

  // Index in Elasticsearch
  await esClient.index({
    index: 'products',
    id: product.id,
    body: {
      name: product.name,
      description: product.description,
      price: product.price,
      brand: product.brand,
      category: product.category,
      tags: product.tags
    }
  })

  res.json(product)
})
```

**Search Query**:
```typescript
app.get('/search', async (req, res) => {
  const { q, brand, minPrice, maxPrice } = req.query

  const results = await esClient.search({
    index: 'products',
    body: {
      query: {
        bool: {
          must: [
            { multi_match: { query: q, fields: ['name^2', 'description'] } }
          ],
          filter: [
            brand && { term: { brand } },
            { range: { price: { gte: minPrice, lte: maxPrice } } }
          ].filter(Boolean)
        }
      },
      aggs: {
        brands: { terms: { field: 'brand' } },
        price_ranges: { histogram: { field: 'price', interval: 50 } }
      }
    }
  })

  res.json({
    products: results.hits.hits,
    facets: results.aggregations
  })
})
```

**Cost**: AWS OpenSearch (Elasticsearch): ~$50-200/month for 10K-100K products

---

## Security Checklist

- [ ] Idempotency keys for all payment requests
- [ ] Verify Stripe webhook signatures
- [ ] Row-level locking for inventory updates
- [ ] Stock reservation with expiration
- [ ] Order status transition validation
- [ ] PCI compliance (use Stripe Elements, never store card numbers)
- [ ] Rate limit checkout endpoints (prevent scalping bots)
- [ ] CSRF protection on cart/checkout
- [ ] Input validation (quantity > 0, price > 0)

---

## Cost Implications

**Payment Processing (Stripe)**:
- 2.9% + $0.30 per transaction
- $10K sales/month → ~$320 fees

**Stripe Tax**:
- 0.5% + $10/month
- $10K sales → $60/month

**Elasticsearch**:
- AWS OpenSearch t3.small: $50/month (10K products)
- $200/month for 100K products

**Email (Abandoned Cart, Order Confirmation)**:
- Resend: $20/month for 50K emails
- SendGrid: $15/month for 40K emails

**Total Infrastructure (10K orders/month)**:
- Stripe fees: $320
- Tax: $60
- Search: $50
- Email: $20
- **Total**: ~$450/month (mostly Stripe fees)
