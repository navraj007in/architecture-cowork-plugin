---
name: "Universal Navigation Patterns"
description: "5 generic navigation patterns (route guards, context scoping, error handling, ephemeral states, dynamic menus) applicable to all web/mobile/desktop applications"
type: "reference"
---

# Universal Navigation Patterns (Advanced / When Applicable)

This reference documents 5 generic navigation patterns for when they're actually needed — **not baseline requirements for all apps**.

**When to use this guide:**
- Your SDL has `product.navigationPatterns` defined (detected by `/architect:blueprint`)
- Scaffold/prototype/design-system are generating pattern-specific code
- You want to understand the full pattern for a feature you're adding

**When you DON'T need this:**
- Simple apps with basic routing (use hardcoded nav)
- MVP projects without multi-user access (no guards needed)
- Single-tenant apps (skip context scoping)
- Form-light apps (skip ephemeral navigation)

This reference is here for when patterns ARE needed. The cowork plugin will only scaffold what your app actually requires.

---

## Pattern 1: Route Guards & Access Control

**What it solves:** Authorization-driven navigation (who can see what)

**Applies to:** Any multi-user system with roles, permissions, or feature flags

**Concepts:**

| Concept | Definition | Example |
|---------|-----------|---------|
| **Guard** | A check that runs before a route is accessible | "User must be logged in to access /dashboard" |
| **Role-based** | Users have roles; different roles see different content | Admin role unlocks `/admin/users` |
| **Feature Flag** | Toggle routes/UI on/off per user segment | Beta feature only visible if `featureFlag: 'beta-feature'` is true |
| **Redirect** | Guide user to appropriate page on guard failure | Fail auth → redirect to `/login`, fail role → show 403 page |

**SDL Schema:**
```yaml
product:
  navigationPatterns:
    - name: "Protected Routes"
      guards:
        - type: "authentication"    # requiresAuth: true
          redirectOnFail: "/login"
        - type: "role"              # roles: ['admin']
          redirectOnFail: "/forbidden"
        - type: "featureFlag"       # featureFlag: 'beta-feature'
          redirectOnFail: "hide-nav-item"
```

**Code Examples:**

**React Guard Component:**
```tsx
// ProtectedRoute.tsx
export function ProtectedRoute({ 
  requiresAuth, 
  roles, 
  featureFlag, 
  redirectOnFail,
  children 
}) {
  const { isAuthenticated, userRoles, featureFlags } = useAuth();
  
  if (requiresAuth && !isAuthenticated) {
    return <Navigate to={redirectOnFail} />;
  }
  
  if (roles && !roles.some(r => userRoles.includes(r))) {
    return <Navigate to="/forbidden" />;
  }
  
  if (featureFlag && !featureFlags[featureFlag]) {
    return <Navigate to="/feature-unavailable" />;
  }
  
  return children;
}

// Usage
<Route path="/admin" element={
  <ProtectedRoute 
    requiresAuth={true} 
    roles={['admin']} 
    redirectOnFail="/forbidden"
  >
    <AdminDashboard />
  </ProtectedRoute>
} />
```

**Backend Guard (Node/Express):**
```ts
// middleware/authGuard.ts
export function authGuard(requiredRoles?: string[]) {
  return (req, res, next) => {
    if (!req.user) {
      return res.status(401).json({ error: 'Unauthorized' });
    }
    
    if (requiredRoles && !requiredRoles.some(r => req.user.roles.includes(r))) {
      return res.status(403).json({ error: 'Forbidden' });
    }
    
    next();
  };
}

// Usage
router.get('/admin/users', authGuard(['admin']), (req, res) => {
  // ...
});
```

**Design Considerations:**
- Guards should be **silent for auth redirects** (no toast, just navigate to login)
- Guards should **show error for permission denials** (toast: "You don't have permission")
- Feature-flagged nav items should be **hidden entirely**, not greyed out
- Deep links to guarded routes should redirect gracefully (not 404)

---

## Pattern 2: Context-Scoped Routing

**What it solves:** Multi-tenant / multi-workspace navigation (user operates within a context)

**Applies to:** SaaS, marketplaces, organizational apps (Slack, GitHub, Figma, Notion, etc.)

**Concepts:**

| Concept | Definition | Example |
|---------|-----------|---------|
| **Context** | A scoped boundary (workspace, organization, account, project) | User switches between "Marketing Team" and "Product Team" workspaces |
| **Context Switcher** | UI to change current context (dropdown, sidebar, modal) | Top-left dropdown showing "Marketing Team ▼" |
| **Scoped Routes** | All routes include context identifier | `/workspace/{id}/dashboard` instead of `/dashboard` |
| **Context-aware Data** | Data loaded respects current context | Switching workspace loads that workspace's projects/users |

**SDL Schema:**
```yaml
product:
  navigationPatterns:
    - name: "Workspace Switching"
      contextualRouting:
        scopes: ["workspace", "organization", "account"]
        routePattern: "/workspace/{id}/..."
        switcherPosition: "top-left"
        switcher:
          trigger: "button"  # or 'dropdown'
          showCurrentName: true
          showUserRole: true
```

**Code Examples:**

**React Context Switcher:**
```tsx
// ContextSwitcher.tsx
export function ContextSwitcher() {
  const { currentWorkspace, workspaces, switchWorkspace } = useContext(WorkspaceContext);
  
  return (
    <select value={currentWorkspace.id} onChange={(e) => switchWorkspace(e.target.value)}>
      {workspaces.map(ws => (
        <option key={ws.id} value={ws.id}>
          {ws.icon} {ws.name} {ws.isAdmin && <Badge>Admin</Badge>}
        </option>
      ))}
    </select>
  );
}
```

**Scoped Router:**
```tsx
// App.tsx
<Routes>
  <Route path="/workspace/:workspaceId/dashboard" element={<Dashboard />} />
  <Route path="/workspace/:workspaceId/projects" element={<Projects />} />
  <Route path="/workspace/:workspaceId/settings" element={<Settings />} />
  {/* Fallback routes without workspace ID redirect to context selector */}
  <Route path="/dashboard" element={<Navigate to={`/workspace/${defaultWorkspace.id}/dashboard`} />} />
</Routes>
```

**API Calls with Context:**
```ts
// services/api.ts
export async function getProjects(workspaceId: string) {
  const response = await fetch(`/api/workspaces/${workspaceId}/projects`);
  return response.json();
}

// Hook
export function useProjects() {
  const { currentWorkspace } = useContext(WorkspaceContext);
  const [projects, setProjects] = useState([]);
  
  useEffect(() => {
    getProjects(currentWorkspace.id).then(setProjects);
  }, [currentWorkspace.id]);
  
  return projects;
}
```

**Design Considerations:**
- Context switcher should be **persistent** in header (always visible)
- Switching context should **preserve page** (go to `/workspace/new-id/dashboard`, not `/dashboard`)
- Context should be **persisted** to localStorage/cookies
- Data should **invalidate** when context changes (reload all queries)
- Should **show user role** in context (admin vs. member) if roles vary per workspace

---

## Pattern 3: Error & Fallback Navigation

**What it solves:** Graceful handling of error states (404, 403, 500, offline)

**Applies to:** All applications

**Concepts:**

| Concept | Definition | Example |
|---------|-----------|---------|
| **Error Page** | Fallback UI when something goes wrong | 404: "Page not found" |
| **Graceful Degradation** | App continues working with reduced functionality | Offline: show cached data, disable submit buttons |
| **Error Boundary** | Catch render errors and show fallback instead of white screen | Child component crashes → show "Something went wrong" |
| **Retry Logic** | Offer user a way to recover from error | Timeout: "Retry" button that refetches |

**SDL Schema:**
```yaml
product:
  navigationPatterns:
    - name: "Error Handling"
      errorHandling:
        patterns:
          - trigger: "404"
            fallback: "/not-found"
            uiComponent: "ErrorPage"
          - trigger: "403"
            fallback: "/forbidden"
            uiComponent: "ErrorPage"
          - trigger: "500"
            fallback: "/error"
            uiComponent: "ErrorPage"
          - trigger: "offline"
            fallback: "cached-routes-only"
            uiComponent: "OfflineBanner"
          - trigger: "timeout"
            fallback: "show-retry-button"
            uiComponent: "TimeoutError"
```

**Code Examples:**

**Error Boundary:**
```tsx
// components/ErrorBoundary.tsx
export class ErrorBoundary extends React.Component {
  state = { hasError: false };
  
  static getDerivedStateFromError(error) {
    return { hasError: true };
  }
  
  componentDidCatch(error, errorInfo) {
    console.error('Caught error:', error, errorInfo);
  }
  
  render() {
    if (this.state.hasError) {
      return <ErrorPage code="500" message="Something went wrong" />;
    }
    return this.props.children;
  }
}

// Usage
<ErrorBoundary>
  <App />
</ErrorBoundary>
```

**Error Pages:**
```tsx
// components/ErrorPage.tsx
export function ErrorPage({ code, message, actionLabel = 'Go Home', onAction }) {
  const icons = {
    404: <Search size={48} className="text-secondary" />,
    403: <Lock size={48} className="text-error" />,
    500: <AlertTriangle size={48} className="text-warning" />,
    offline: <WifiOff size={48} className="text-warning" />,
  };
  
  return (
    <div className="flex flex-col items-center justify-center min-h-screen bg-surface">
      {icons[code]}
      <h1 className="text-2xl font-bold text-text-primary mt-4">
        {code === 404 ? 'Page not found' : 'Something went wrong'}
      </h1>
      <p className="text-text-secondary mt-2">{message}</p>
      <button onClick={onAction} className="btn btn-primary mt-6">
        {actionLabel}
      </button>
    </div>
  );
}
```

**Offline Detection:**
```tsx
// hooks/useOfflineStatus.ts
export function useOfflineStatus() {
  const [isOffline, setIsOffline] = useState(!navigator.onLine);
  
  useEffect(() => {
    const handleOnline = () => setIsOffline(false);
    const handleOffline = () => setIsOffline(true);
    
    window.addEventListener('online', handleOnline);
    window.addEventListener('offline', handleOffline);
    
    return () => {
      window.removeEventListener('online', handleOnline);
      window.removeEventListener('offline', handleOffline);
    };
  }, []);
  
  return isOffline;
}

// App.tsx
export function App() {
  const isOffline = useOfflineStatus();
  
  return (
    <>
      {isOffline && (
        <div className="bg-warning text-white p-2 text-center">
          You're offline. Some features may not work.
        </div>
      )}
      <Routes>...</Routes>
    </>
  );
}
```

**Design Considerations:**
- Error pages should **match app design** (use same palette, fonts, layout structure)
- Should include **helpful action** (go home, retry, contact support)
- Should **not** be generic (personalize by error code)
- Offline UI should **not block app** (show banner, let user browse cached content)
- Timeout errors should offer **explicit retry** button (don't auto-retry silently)

---

## Pattern 4: Ephemeral / Stateful Navigation

**What it solves:** Modals, sheets, overlays don't create new routes (state-driven instead of URL-driven)

**Applies to:** Apps with modals, wizards, drawers, side panels (most modern apps)

**Concepts:**

| Concept | Definition | Example |
|---------|-----------|---------|
| **Ephemeral State** | UI state that doesn't change the URL | Opening a modal, expanding sidebar |
| **Modal Stack** | Multiple modals can layer on top of each other | Dialog 1 → Dialog 2 → Dialog 3 |
| **Wizard Steps** | Multi-step flow within a single "route" | Step 1, Step 2, Step 3 of sign-up form |
| **History Management** | Back button should close modal (not navigate to previous route) | Close modal = go back in modal stack, then go back to previous page |

**SDL Schema:**
```yaml
product:
  navigationPatterns:
    - name: "Ephemeral Navigation"
      ephemeralStates:
        - type: "modal"
          priority: "overlay"
          history: "ephemeral"
          closeAction: "pop-from-stack"
        - type: "sheet"
          priority: "overlay"
          history: "ephemeral"
        - type: "drawer"
          priority: "overlay"
          history: "ephemeral"
        - type: "wizard"
          priority: "replace-page"
          history: "ephemeral"
```

**Code Examples:**

**Modal State Management:**
```tsx
// hooks/useModalStack.ts
export function useModalStack() {
  const [modals, setModals] = useState<Modal[]>([]);
  
  const openModal = (id: string, data?: any) => {
    setModals(prev => [...prev, { id, data }]);
  };
  
  const closeModal = () => {
    setModals(prev => prev.slice(0, -1));
  };
  
  const closeAllModals = () => {
    setModals([]);
  };
  
  return { modals, openModal, closeModal, closeAllModals };
}

// Usage
export function App() {
  const { modals, openModal, closeModal } = useModalStack();
  
  return (
    <>
      <Routes>...</Routes>
      {modals.map((modal, index) => (
        <Modal 
          key={modal.id} 
          isOpen={index === modals.length - 1}
          onClose={closeModal}
        >
          {/* Modal content based on modal.id */}
        </Modal>
      ))}
    </>
  );
}
```

**Back Button Handling:**
```tsx
// Hook to intercept back button
export function useBackButton(onBack: () => void) {
  useEffect(() => {
    const handlePopState = () => {
      onBack();
      // Push a dummy state so back button works again
      window.history.pushState(null, '', window.location.href);
    };
    
    window.history.pushState(null, '', window.location.href);
    window.addEventListener('popstate', handlePopState);
    
    return () => window.removeEventListener('popstate', handlePopState);
  }, [onBack]);
}

// Usage
const { modals, closeModal } = useModalStack();
useBackButton(() => {
  if (modals.length > 0) closeModal();
  else history.back();
});
```

**Wizard Component:**
```tsx
// components/Wizard.tsx
export function Wizard({ steps, onComplete }) {
  const [currentStep, setCurrentStep] = useState(0);
  
  const handleNext = () => {
    if (currentStep < steps.length - 1) {
      setCurrentStep(currentStep + 1);
    } else {
      onComplete();
    }
  };
  
  const handleBack = () => setCurrentStep(Math.max(0, currentStep - 1));
  
  return (
    <div>
      <div className="mb-6">
        {steps.map((step, i) => (
          <div key={i} className={i <= currentStep ? 'completed' : ''}>
            {step.label}
          </div>
        ))}
      </div>
      {steps[currentStep].component}
      <div className="flex gap-2">
        <button onClick={handleBack} disabled={currentStep === 0}>Back</button>
        <button onClick={handleNext}>
          {currentStep === steps.length - 1 ? 'Complete' : 'Next'}
        </button>
      </div>
    </div>
  );
}
```

**Design Considerations:**
- Modals should **not change URL** (URL = data source of truth, not modal state)
- Back button should **close modal first**, then navigate back
- Multiple modals should **stack visually** (darkening / dimming previous ones)
- Closing modal should **preserve page state** (don't reload)
- Wizard should be **single scrollable view** with step indicator, not multiple pages

---

## Pattern 5: Data-Driven Navigation

**What it solves:** Navigation structure comes from backend (not hardcoded in frontend)

**Applies to:** Admin dashboards, configurable apps, feature-flag-driven UIs

**Concepts:**

| Concept | Definition | Example |
|---------|-----------|---------|
| **Backend Menu** | Navigation menu structure fetched from API | `/api/nav/menu` returns menu items based on user role |
| **Feature Flags** | Show/hide menu items per user segment | "AI Features" menu only visible if feature flag enabled |
| **Role-based Menu** | Different roles see different menu items | Admin sees "Settings", user doesn't |
| **Internationalized** | Menu labels translated based on user language | "Dashboard" vs. "Tableau de Bord" |

**SDL Schema:**
```yaml
product:
  navigationPatterns:
    - name: "Dynamic Navigation"
      dynamicNavigation:
        source: "backend"  # or 'feature-flags', 'static'
        strategy: "generate-from-roles"
        cacheStrategy: "client"
        invalidateOn: "role-change"
        endpoints:
          - "/api/nav/menu"
          - "/api/feature-flags"
```

**Code Examples:**

**Navigation Config (Backend):**
```ts
// server/routes/nav.ts
router.get('/api/nav/menu', authGuard(), async (req, res) => {
  const user = req.user;
  
  const menu = [
    { id: 'dashboard', label: 'Dashboard', icon: 'home', href: '/dashboard', roles: ['*'] },
    { id: 'projects', label: 'Projects', icon: 'folder', href: '/projects', roles: ['*'] },
    { id: 'team', label: 'Team', icon: 'users', href: '/team', roles: ['admin', 'manager'] },
    { id: 'settings', label: 'Settings', icon: 'gear', href: '/settings', roles: ['admin'] },
  ];
  
  // Filter by user role
  const filtered = menu.filter(item => 
    item.roles.includes('*') || item.roles.some(r => user.roles.includes(r))
  );
  
  res.json(filtered);
});
```

**Frontend Navigation Hook:**
```tsx
// hooks/useNavMenu.ts
export function useNavMenu() {
  const { user } = useAuth();
  const [menu, setMenu] = useState<NavItem[]>([]);
  const [loading, setLoading] = useState(true);
  
  useEffect(() => {
    const fetchMenu = async () => {
      try {
        const res = await fetch('/api/nav/menu');
        const data = await res.json();
        setMenu(data);
      } catch (error) {
        console.error('Failed to fetch menu:', error);
        setMenu([]); // fallback to empty
      } finally {
        setLoading(false);
      }
    };
    
    fetchMenu();
  }, [user]); // Refetch when user changes
  
  return { menu, loading };
}

// Navigation Component
export function Navigation() {
  const { menu, loading } = useNavMenu();
  
  if (loading) return <Skeleton count={5} />;
  
  return (
    <nav>
      {menu.map(item => (
        <a key={item.id} href={item.href} className="nav-item">
          <Icon name={item.icon} />
          <span>{item.label}</span>
        </a>
      ))}
    </nav>
  );
}
```

**Feature Flag Integration:**
```tsx
// hooks/useFeatureFlags.ts
export function useFeatureFlags() {
  const { user } = useAuth();
  const [flags, setFlags] = useState<Record<string, boolean>>({});
  
  useEffect(() => {
    const fetchFlags = async () => {
      const res = await fetch('/api/feature-flags', {
        headers: { 'X-User-Id': user.id }
      });
      const data = await res.json();
      setFlags(data.flags);
    };
    
    fetchFlags();
  }, [user.id]);
  
  return flags;
}

// Usage
const flags = useFeatureFlags();

<nav>
  <NavItem href="/dashboard">Dashboard</NavItem>
  {flags['ai-features'] && <NavItem href="/ai">AI Tools</NavItem>}
  {flags['beta-analytics'] && <NavItem href="/analytics-v2">Analytics (Beta)</NavItem>}
</nav>
```

**Caching Strategy:**
```tsx
// utils/navCache.ts
const CACHE_KEY = 'nav_menu_cache';
const CACHE_TTL = 5 * 60 * 1000; // 5 minutes

export async function getCachedNavMenu() {
  const cached = localStorage.getItem(CACHE_KEY);
  
  if (cached) {
    const { data, timestamp } = JSON.parse(cached);
    if (Date.now() - timestamp < CACHE_TTL) {
      return data;
    }
  }
  
  const res = await fetch('/api/nav/menu');
  const data = await res.json();
  
  localStorage.setItem(CACHE_KEY, JSON.stringify({
    data,
    timestamp: Date.now()
  }));
  
  return data;
}
```

**Design Considerations:**
- Backend menu should **fail gracefully** (show hardcoded fallback if API fails)
- Menu should **cache** (don't refetch on every render)
- Should **invalidate cache** when user role changes
- Feature flags should be **checked on load** and periodically updated (not require refresh)
- Menu items should **include icons** for better UX than text alone
- Should support **deep nesting** (submenus, collapsible sections)

---

## Implementation Checklist

When implementing these 5 patterns, follow this checklist:

### Route Guards
- [ ] Define guard types (auth, role, feature flag) in SDL
- [ ] Create ProtectedRoute component
- [ ] Create useRouteGuards hook
- [ ] Create mock AuthContext for prototyping
- [ ] Add error messages (toast) on guard failure
- [ ] Test with different roles and feature flags

### Context Scoping
- [ ] Define context scopes in SDL (workspace, org, account, etc.)
- [ ] Create ContextSwitcher component (dropdown in header)
- [ ] Create context hook (useCurrentContext)
- [ ] Scope all routes to include context ID
- [ ] Create useEffect to reload data when context changes
- [ ] Persist current context to localStorage

### Error Handling
- [ ] Create ErrorBoundary component
- [ ] Create ErrorPage component with 404, 403, 500, offline variants
- [ ] Add error routes to router
- [ ] Implement offline detection (useOfflineStatus hook)
- [ ] Add graceful degradation (show cached data offline)
- [ ] Test error pages visually

### Ephemeral Navigation
- [ ] Choose modal state management (Context, Zustand, Redux, etc.)
- [ ] Create useModalStack hook
- [ ] Create Modal component
- [ ] Intercept back button to close modal first
- [ ] Test modal stacking
- [ ] Test history/back button behavior

### Data-Driven Navigation
- [ ] Design nav menu API endpoint
- [ ] Implement backend endpoint to return menu based on role
- [ ] Create useNavMenu hook
- [ ] Create Navigation component that renders dynamic menu
- [ ] Implement feature flag fetching
- [ ] Add caching with cache invalidation
- [ ] Test with different roles and feature flags

---

## Testing Considerations

**Route Guards:**
- Test with authenticated user (should pass)
- Test with unauthenticated user (should redirect to login)
- Test with wrong role (should redirect to forbidden)
- Test with feature flag disabled (should hide nav item or show unavailable page)

**Context Scoping:**
- Switch context and verify route changes
- Switch context and verify data reloads
- Verify localStorage persists context on reload
- Verify deep links work with different contexts

**Error Handling:**
- Trigger 404 (navigate to invalid route)
- Trigger component error (throw error in component)
- Simulate offline mode (DevTools network offline)
- Verify error pages are styled correctly

**Ephemeral Navigation:**
- Open modal and press back button (should close modal)
- Open multiple modals and press back (should close one at a time)
- Reload page with modal open (modal should be closed)
- Verify modal doesn't appear in browser history

**Data-Driven Navigation:**
- Login as admin (should see admin menu items)
- Login as user (should see user menu items)
- Toggle feature flag (should show/hide items without reload)
- Go offline (cached menu should still appear)

---

## References

- [OWASP Authentication Cheat Sheet](https://cheatsheetseries.owasp.org/cheatsheets/Authentication_Cheat_Sheet.html)
- [React Router v6 Protected Routes](https://reactrouter.com/start/library/protection-routes)
- [Error Boundaries - React Docs](https://react.dev/reference/react/Component#catching-rendering-errors-with-an-error-boundary)
- [Modal Dialog Pattern - WAI-ARIA](https://www.w3.org/WAI/ARIA/apg/patterns/dialogmodal/)
- [Feature Flags Best Practices - LaunchDarkly](https://launchdarkly.com/blog/feature-flag-best-practices/)
