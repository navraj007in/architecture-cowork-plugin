---
name: Testing Strategy
description: Test naming conventions, fixture patterns, mocking strategies, and coverage thresholds by stage
---

# Testing Strategy Skill

Covers unit, integration, and e2e test patterns for all supported frameworks.

## Test File Organization

### Folder Structure
- **Unit tests:** co-locate with source files
  - `src/services/user.ts` → `src/services/__tests__/user.test.ts` (Jest/Vitest)
  - `src/services/user.ts` → `src/services/test_user.py` (pytest)
- **Integration tests:** separate `tests/` directory at project root
  - `tests/integration/auth.test.ts`
  - `tests/integration/database.test.ts`
- **E2E tests:** separate `e2e/` or `tests/e2e/` directory
  - `e2e/flows/login.test.ts`
  - `e2e/flows/checkout.test.ts`

### File Naming Convention
- Unit: `<module>.test.ts` or `<module>_test.py`
- Integration: `<feature>.integration.test.ts` or `test_<feature>.py`
- E2E: `<flow>.e2e.test.ts` or `test_<flow>_e2e.py`

## Test Structure: Arrange-Act-Assert

All tests MUST follow AAA pattern:

```typescript
describe('UserService', () => {
  describe('createUser', () => {
    it('should create a user with valid email and name', () => {
      // ARRANGE: Setup test data, mocks, fixtures
      const email = 'alice@example.com';
      const name = 'Alice Chen';
      
      // ACT: Call the function under test
      const user = service.createUser(email, name);
      
      // ASSERT: Verify the result
      expect(user.email).toBe(email);
      expect(user.name).toBe(name);
      expect(user.id).toBeDefined();
    });
  });
});
```

**Golden rule:** One logical assertion per test (one reason to fail).

## Test Naming: Descriptive, Not Clever

❌ BAD:
```typescript
it('works', () => { ... });
it('user creation 1', () => { ... });
```

✅ GOOD:
```typescript
it('should create a user with valid email and return user object with id', () => { ... });
it('should reject email without @ symbol', () => { ... });
it('should hash password before storing in database', () => { ... });
```

Pattern: `should [what happens] [given conditions if not obvious]`

## Framework-Specific Setup

### Node.js / TypeScript (Jest / Vitest)
```typescript
// jest.config.js
module.exports = {
  preset: 'ts-jest',
  testEnvironment: 'node',
  roots: ['<rootDir>/src', '<rootDir>/tests'],
  testMatch: ['**/__tests__/**/*.ts', '**/*.test.ts'],
  collectCoverageFrom: [
    'src/**/*.ts',
    '!src/**/*.d.ts',
    '!src/index.ts'
  ],
  coverageThreshold: {
    global: {
      branches: 80,
      functions: 80,
      lines: 80,
      statements: 80
    }
  }
};

// tsconfig.test.json
{
  "extends": "./tsconfig.json",
  "compilerOptions": {
    "jsx": "react",
    "types": ["jest", "node"]
  }
}
```

### Python (pytest)
```python
# pytest.ini
[pytest]
testpaths = tests
python_files = test_*.py *_test.py
python_classes = Test*
python_functions = test_*
addopts = --verbose --strict-markers
markers =
  unit: unit tests
  integration: integration tests
  slow: slow running tests

# conftest.py — shared fixtures
import pytest

@pytest.fixture
def sample_user():
    return {'id': 1, 'email': 'test@example.com', 'name': 'Test User'}
```

### Go (standard testing)
```go
// *_test.go convention
package user

import "testing"

func TestCreateUser(t *testing.T) {
    user := CreateUser("alice@example.com", "Alice")
    if user.Email != "alice@example.com" {
        t.Errorf("expected %q, got %q", "alice@example.com", user.Email)
    }
}
```

### .NET (xUnit)
```csharp
public class UserServiceTests
{
    [Fact]
    public void CreateUser_WithValidEmail_ReturnsUserWithId()
    {
        // Arrange
        var service = new UserService();
        
        // Act
        var user = service.CreateUser("alice@example.com", "Alice");
        
        // Assert
        Assert.NotNull(user.Id);
        Assert.Equal("alice@example.com", user.Email);
    }
}
```

## Mocking Strategy

### Database Mocks (Unit Tests)
Use **in-memory** database for unit tests when possible:

```typescript
// jest.config.js for Node backend
module.exports = {
  setupFilesAfterEnv: ['<rootDir>/tests/setup.ts']
};

// tests/setup.ts
import { PrismaClient } from '@prisma/client';

beforeAll(async () => {
  // Point to test database
  process.env.DATABASE_URL = 'file:./test.db';
  await prisma.$executeRawUnsafe('PRAGMA foreign_keys = OFF');
});

afterEach(async () => {
  // Clean up between tests
  await prisma.$queryRaw`DELETE FROM "User"`;
  await prisma.$queryRaw`DELETE FROM "Post"`;
});

afterAll(async () => {
  await prisma.$disconnect();
});
```

### External Service Mocks (Unit Tests)
Mock HTTP calls, external APIs, payment gateways:

```typescript
// jest.mock for modules
jest.mock('../lib/stripe', () => ({
  createPayment: jest.fn().mockResolvedValue({ id: 'pay_123', status: 'succeeded' })
}));

// Manual mock for fetch
global.fetch = jest.fn(() =>
  Promise.resolve({
    json: () => Promise.resolve({ data: [] })
  })
);
```

### Real Database (Integration Tests)
Use **actual test database** for integration tests:

```typescript
// tests/integration/setup.ts
beforeAll(async () => {
  // Spin up test PostgreSQL via docker-compose.test.yml
  process.env.DATABASE_URL = 'postgresql://test:test@localhost:5433/test_db';
  await prisma.$executeRawUnsafe('CREATE SCHEMA IF NOT EXISTS tests');
});

afterAll(async () => {
  await prisma.$executeRawUnsafe('DROP SCHEMA tests CASCADE');
});
```

**Rule:** If a test needs the database to run, it's an integration test, not a unit test. Don't mock the database for integration tests.

## Fixture Patterns

### Shared Fixtures (Reusable Test Data)

```typescript
// tests/fixtures/user.fixtures.ts
export const validUser = {
  email: 'alice@example.com',
  name: 'Alice Chen',
  password: 'SecurePass123!'
};

export const adminUser = {
  ...validUser,
  role: 'admin'
};

export const inactiveUser = {
  ...validUser,
  status: 'inactive'
};

// In test file
import { validUser, adminUser } from './fixtures/user.fixtures';

it('should allow admin to create users', () => {
  const created = service.createUser(validUser, { createdBy: adminUser });
  expect(created.createdBy).toBe(adminUser.id);
});
```

### Factory Pattern (Dynamic Test Data)

```typescript
// tests/factories/user.factory.ts
class UserFactory {
  static async create(overrides = {}) {
    const defaults = {
      email: `user-${Date.now()}@example.com`,
      name: 'Test User',
      role: 'user'
    };
    return prisma.user.create({
      data: { ...defaults, ...overrides }
    });
  }
  
  static async createMany(count, overrides = {}) {
    return Promise.all(
      Array.from({ length: count }).map(() => this.create(overrides))
    );
  }
}

// In test
const users = await UserFactory.createMany(10, { role: 'admin' });
expect(users).toHaveLength(10);
```

## Coverage Thresholds by Stage

### MVP Stage
- **Unit tests:** ≥ 70% coverage (critical paths only)
- **Integration tests:** ≥ 5 per service (authentication, CRUD, error cases)
- **E2E tests:** ≥ 2 per major flow (happy path + error case)
- **Requirement:** Tests must run in CI before merge

### Growth Stage
- **Unit tests:** ≥ 80% coverage (all public APIs)
- **Integration tests:** ≥ 10 per service (edge cases, race conditions)
- **E2E tests:** ≥ 5 per major flow (happy path, errors, edge cases)
- **Requirement:** Failed tests block merge, coverage reports published

### Enterprise Stage
- **Unit tests:** ≥ 85% coverage (all code paths including errors)
- **Integration tests:** ≥ 15 per service + contract tests
- **E2E tests:** ≥ 10 per major flow + performance tests
- **Requirement:** Coverage must improve or stay same; no regression allowed

## Test Execution

### NPM Script Convention
```json
{
  "scripts": {
    "test": "jest",
    "test:watch": "jest --watch",
    "test:coverage": "jest --coverage",
    "test:unit": "jest --testPathPattern=__tests__",
    "test:integration": "jest --testPathPattern=integration",
    "test:e2e": "playwright test"
  }
}
```

### Python Convention
```bash
pytest                          # all tests
pytest -m unit                  # unit tests only
pytest -m integration           # integration tests
pytest -v --cov=src            # with coverage
```

### Go Convention
```bash
go test ./...                   # all tests
go test -cover ./...           # with coverage
go test -run TestCreateUser    # specific test
```

## Async / Await Testing

### TypeScript (Jest)
```typescript
// Always return promise or use async/await
it('should fetch user by id', async () => {
  const user = await service.getUserById(1);
  expect(user.id).toBe(1);
});

// Expect promises to resolve/reject
it('should reject invalid id', async () => {
  await expect(service.getUserById(-1)).rejects.toThrow('Invalid ID');
});
```

### Python (pytest)
```python
import pytest

@pytest.mark.asyncio
async def test_fetch_user():
    user = await service.get_user(1)
    assert user.id == 1

# Or use sync wrapper
from asyncio import run

def test_sync_wrapper():
    user = run(service.get_user(1))
    assert user.id == 1
```

## Skip & Mark Patterns

### Skip Flaky Tests
```typescript
// Jest
it.skip('should handle network timeout', () => {
  // Re-enable after fixing flakiness
});

// pytest
@pytest.mark.skip(reason="flaky, TODO: fix race condition")
def test_concurrent_updates():
    pass
```

### Mark Slow Tests
```typescript
// jest.config.js
module.exports = {
  testTimeout: 30000  // 30s for slow tests
};

// In test
jest.setTimeout(5000); // override for this test
```

### Mark as WIP (Work in Progress)
```typescript
it.todo('should support bulk user import');
```

## CI/CD Integration

### GitHub Actions
```yaml
- name: Run Tests
  run: npm test -- --coverage
  
- name: Upload Coverage
  uses: codecov/codecov-action@v3
  with:
    files: ./coverage/lcov.info
```

### Fail on Coverage Drop
```yaml
- name: Check Coverage
  run: |
    COVERAGE=$(npm test -- --coverage | grep Lines | awk '{print $NF}' | sed 's/%//')
    if (( $(echo "$COVERAGE < 80" | bc -l) )); then
      echo "Coverage $COVERAGE% below threshold 80%"
      exit 1
    fi
```

## Best Practices Checklist

- ✓ Each test file tests ONE class/module
- ✓ Each test method tests ONE behavior
- ✓ Test names describe the BEHAVIOR, not the method
- ✓ AAA structure (Arrange, Act, Assert)
- ✓ No test interdependencies (tests can run in any order)
- ✓ Mock external dependencies (APIs, databases, file system)
- ✓ Use real database for integration tests only
- ✓ Clean up after each test (teardown)
- ✓ Fixtures for reusable test data
- ✓ Factories for dynamic test data generation
- ✓ Timeouts for async tests
- ✓ Descriptive assertion messages
- ✓ One assertion per test when possible (one reason to fail)
- ✓ Avoid testing private implementation details
- ✓ Test behavior from the outside (black box)
