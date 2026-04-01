# Clean Code — Frontend Rules

Rules CC-F1, CC-F2, CC-F3. Applies to component-based frontend runtimes: React, Vue, Svelte, Angular, SwiftUI, Jetpack Compose. Loaded by the implementer for frontend layers and by the reviewer in Check 5 for frontend diffs.

---

## CC-F1: Component Size

The most common AI-generated frontend quality issue: all JSX/template logic dumped into one component file. A component that is too large is impossible to test in isolation, impossible to reuse, and impossible to reason about.

### Trigger — implementer

Before writing the JSX/template return block, count the logical sections the component must render (e.g. page header, filter bar, data table, pagination, modal, empty state). If there are 3+ distinct sections, design the component hierarchy **before writing any JSX**:

1. Name each child component after its purpose (`OrdersTable`, `FilterBar`, `EmptyOrdersState`)
2. Decide which props each child needs — only the data it renders, nothing more
3. Write each child component first, then compose them in the parent

Do not write a 200-line JSX block and intend to decompose later. Decomposition is a design decision, not a refactor.

### Trigger — reviewer

Scan added component files for:
- Total line count of the component function/class body exceeding the runtime threshold
- JSX/template return blocks with nesting depth exceeding the depth limit
- Repeated JSX patterns (3+ structurally identical elements that should be a mapped component)

### Runtime thresholds

| Runtime | File line threshold | Template depth limit | Notes |
|---------|--------------------|--------------------|-------|
| React (TSX/JSX) | 150 lines | 4 levels of JSX nesting | Count from `return (` to closing `)` |
| Vue SFC | 100 lines in `<template>` | 4 levels | Count template block only |
| Svelte | 100 lines of markup | 4 levels | Count markup, not script block |
| Angular | 50 lines in template | 3 levels | Angular templates are more declarative; deeper nesting is a stronger signal |
| SwiftUI | 80 lines in `body` | 4 levels of `View` nesting | Count from `var body: some View {` to closing `}` |
| Jetpack Compose | 80 lines per `@Composable` | 4 levels | Count the composable function body |

**Depth counting:** count HTML/JSX element nesting, not indentation levels. A `<div>` containing a `<ul>` containing an `<li>` containing a `<span>` is 4 levels deep.

### Decomposition rules

When a component exceeds its threshold:

1. **Identify logical sections** — each distinct UI concern (header, list, item, empty state, loading state, modal, form) is a candidate for extraction
2. **Extract to named components** — name after purpose, not position (`ProductCard` not `ListItem`, `OrderSummaryHeader` not `TopSection`)
3. **Co-locate by default** — place extracted components in the same directory as the parent. Move to a shared `components/` directory only when 2+ other components import them
4. **One component per file** — do not define multiple exported components in the same file

### Before / After

```tsx
// BEFORE — 180 lines, all concerns in one component
export function OrdersPage() {
  const [orders, setOrders] = useState<Order[]>([])
  const [filter, setFilter] = useState('')
  const [selectedOrder, setSelectedOrder] = useState<Order | null>(null)
  const [isLoading, setIsLoading] = useState(true)

  useEffect(() => {
    fetchOrders(filter).then(data => { setOrders(data); setIsLoading(false) })
  }, [filter])

  return (
    <div className="orders-page">
      <div className="page-header">
        <h1>Orders</h1>
        <input value={filter} onChange={e => setFilter(e.target.value)} placeholder="Filter..." />
      </div>
      {isLoading ? (
        <div className="loading-spinner">...</div>  // 20 more lines
      ) : orders.length === 0 ? (
        <div className="empty-state">...</div>       // 15 more lines
      ) : (
        <table>                                       // 60 more lines of table JSX
          <thead>...</thead>
          <tbody>
            {orders.map(order => (
              <tr key={order.id}>
                // 15 lines of cell JSX per row
              </tr>
            ))}
          </tbody>
        </table>
      )}
      {selectedOrder && (
        <div className="modal">...</div>             // 40 more lines of modal JSX
      )}
    </div>
  )
}

// AFTER — parent is 25 lines; each concern is a named, testable component
export function OrdersPage() {
  const { orders, isLoading, filter, setFilter } = useOrders()
  const [selectedOrder, setSelectedOrder] = useState<Order | null>(null)

  return (
    <div className="orders-page">
      <OrdersPageHeader filter={filter} onFilterChange={setFilter} />
      {isLoading && <LoadingSpinner />}
      {!isLoading && orders.length === 0 && <EmptyOrdersState />}
      {!isLoading && orders.length > 0 && (
        <OrdersTable orders={orders} onSelectOrder={setSelectedOrder} />
      )}
      {selectedOrder && (
        <OrderDetailModal order={selectedOrder} onClose={() => setSelectedOrder(null)} />
      )}
    </div>
  )
}
```

---

## CC-F2: Props Interface

### Trigger — implementer

Before defining a component's props, verify:
1. The component receives only the data it renders — not a parent's entire state object or store slice
2. The props count does not exceed 6. If it does, apply CC-F1 first (the component is doing too much) then re-evaluate
3. Prop names describe what the data is, not where it came from (`userId` not `currentUserFromStore`)
4. Callback prop names follow the `on<Event>` convention: `onSubmit`, `onChange`, `onClose`, `onSelectOrder`

### Trigger — reviewer

Scan added component definitions for:
- Props that are typed as a full store slice, context value, or parent state object (e.g. `props: AppState`, `props: { store: RootStore }`) — the component should receive only what it renders
- Props count > 6 (same detection as CC-I1 but applied to component props)
- Prop drilling: a component passes a prop straight through to a child without using it — flag as WARNING

### Constraint

Each component's props are the **minimal interface** required to render it correctly. A component does not know about its parent's state management solution. It receives plain data and callback functions.

| Anti-pattern | Correct pattern |
|-------------|----------------|
| `<OrdersTable store={store} />` | `<OrdersTable orders={orders} onSelect={handleSelect} />` |
| `<OrderCard user={currentUser} order={order} />` (when only `user.name` is used) | `<OrderCard userName={currentUser.name} order={order} />` |
| `<Modal {...props} />` (spreading all parent props) | `<Modal title={props.title} onClose={props.onClose} />` |

**Props count by runtime:**

| Runtime | Max props before flag | Notes |
|---------|----------------------|-------|
| React | 6 | Includes callbacks |
| Vue | 6 | Props + emits combined |
| Svelte | 6 | `export let` declarations |
| Angular | 6 | `@Input()` + `@Output()` combined |
| SwiftUI | 6 | Initializer parameters |
| Jetpack Compose | 6 | Function parameters |

---

## CC-F3: Logic Extraction

### Trigger — implementer

Business logic, data fetching, complex derived state, and side effects do not belong in the component render function. If any of the following are present in the component body, extract them before writing more JSX:

- `fetch(...)` or API client calls
- Complex `useMemo`/`useCallback`/`computed` expressions longer than 3 lines
- Multiple `useEffect` / `onMounted` / `ngOnInit` calls managing unrelated concerns
- State transformations beyond simple toggles (`setIsOpen(!isOpen)` is fine inline; filtering and sorting arrays is not)

### Trigger — reviewer

Scan added component files for:
- Direct `fetch(` or API client calls inside the component function body (not in a hook/composable/service)
- 3+ `useState` calls managing unrelated concerns — signal that logic should be extracted
- `useEffect` with a non-trivial body (> 5 lines) — signal for custom hook extraction
- Inline data transformation in JSX: `{orders.filter(...).sort(...).map(...)}` where the chain is > 2 operations

### Extraction targets by runtime

| Runtime | Logic extraction target | Location |
|---------|------------------------|---------|
| React | Custom hook `use<Name>` | `hooks/use<Name>.ts` or co-located `use<Name>.ts` |
| Vue | Composable `use<Name>` | `composables/use<Name>.ts` |
| Svelte | Store or `.ts` module | `stores/<name>.ts` |
| Angular | Service with DI | `<feature>/<name>.service.ts` |
| SwiftUI | `@Observable` ViewModel or `@State` with computed properties | `<Feature>ViewModel.swift` |
| Jetpack Compose | `ViewModel` + `StateHolder` | `<Feature>ViewModel.kt` |

### Before / After

```tsx
// BEFORE — fetch, transform, and derived state all in the component
export function ProductList({ categoryId }: { categoryId: string }) {
  const [products, setProducts] = useState<Product[]>([])
  const [isLoading, setIsLoading] = useState(true)
  const [error, setError] = useState<string | null>(null)
  const [sortOrder, setSortOrder] = useState<'asc' | 'desc'>('asc')

  useEffect(() => {
    setIsLoading(true)
    api.get(`/products?categoryId=${categoryId}`)
      .then(res => { setProducts(res.data); setIsLoading(false) })
      .catch(err => { setError(err.message); setIsLoading(false) })
  }, [categoryId])

  const sorted = [...products].sort((a, b) =>
    sortOrder === 'asc' ? a.price - b.price : b.price - a.price
  )

  return ( /* JSX using sorted, isLoading, error, setSortOrder */ )
}

// AFTER — logic in a custom hook; component renders only
// hooks/useProducts.ts
export function useProducts(categoryId: string) {
  const [products, setProducts] = useState<Product[]>([])
  const [isLoading, setIsLoading] = useState(true)
  const [error, setError] = useState<string | null>(null)
  const [sortOrder, setSortOrder] = useState<'asc' | 'desc'>('asc')

  useEffect(() => {
    setIsLoading(true)
    api.get(`/products?categoryId=${categoryId}`)
      .then(res => { setProducts(res.data); setIsLoading(false) })
      .catch(err => { setError(err.message); setIsLoading(false) })
  }, [categoryId])

  const sortedProducts = [...products].sort((a, b) =>
    sortOrder === 'asc' ? a.price - b.price : b.price - a.price
  )

  return { products: sortedProducts, isLoading, error, sortOrder, setSortOrder }
}

// ProductList.tsx — pure rendering
export function ProductList({ categoryId }: { categoryId: string }) {
  const { products, isLoading, error, sortOrder, setSortOrder } = useProducts(categoryId)
  return ( /* JSX — no logic, just rendering */ )
}
```
