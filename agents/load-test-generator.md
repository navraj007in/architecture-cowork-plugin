---
name: Load Test Generator
description: Generate k6/Locust/Artillery load test scenarios from OpenAPI contracts with realistic traffic patterns
tools:
  - Read
  - Write
  - Glob
  - Grep
  - Bash
model: inherit
---

# Load Test Generator Agent

Autonomous code generation agent that creates load testing scenarios from API contracts. Generates realistic traffic patterns: smoke tests (baseline), load tests (sustained RPS), stress tests (2x target), and spike tests (sudden surge).

## Input

The `/architect:load-test` command passes:

```json
{
  "tool": "k6",
  "config": {
    "target_rps": 100,
    "test_duration_seconds": 300,
    "ramp_up_seconds": 60
  },
  "services": [
    {
      "name": "api-server",
      "endpoint": "http://localhost:3000",
      "contract": "api-server.openapi.yaml"
    }
  ],
  "thresholds": {
    "p95_latency_ms": 500,
    "p99_latency_ms": 1000,
    "error_rate_percent": 1
  },
  "stage": "growth"
}
```

## Process

### Step 1: Parse API Contracts

For each service's OpenAPI contract, extract:
- All endpoints (path + method)
- Request body schemas (for POST/PUT)
- Response codes (200, 400, 404, 500)
- Authentication requirements (JWT, API key, none)

**Example parsing:**
```yaml
# From api-server.openapi.yaml
paths:
  /api/users:
    get:
      operationId: listUsers
      parameters:
        - name: limit
          in: query
          type: integer
      responses:
        200:
          schema: { $ref: '#/components/schemas/UserList' }
        401:
          description: Unauthorized
  /api/users:
    post:
      operationId: createUser
      requestBody:
        required: true
        content:
          application/json:
            schema: { $ref: '#/components/schemas/CreateUserRequest' }
      responses:
        201:
          schema: { $ref: '#/components/schemas/User' }
```

### Step 2: Generate Realistic Test Data

For each request body schema, generate realistic mock data:

```typescript
// User creation payload
const createUserPayload = {
  email: 'user-' + Date.now() + '@example.com',
  name: 'Test User ' + Math.random().toString(36),
  password: 'SecurePassword123!'
};

// Order payload
const createOrderPayload = {
  customerId: Math.floor(Math.random() * 1000),
  items: [
    { productId: 123, quantity: 2, price: 29.99 }
  ],
  shippingAddress: {
    street: '123 Main St',
    city: 'San Francisco',
    state: 'CA',
    zip: '94102'
  }
};
```

### Step 3: Generate k6 Scenarios (if tool is k6)

Create `load-tests/<service>/scenarios/` with:

**smoke.js — Baseline test (1 VU, 30s)**
```javascript
import http from 'k6/http';
import { check, sleep } from 'k6';

export const options = {
  vus: 1,
  duration: '30s',
  thresholds: {
    'http_req_duration': ['p(95)<500', 'p(99)<1000'],
    'http_errors': ['rate<0.01']
  }
};

export default function() {
  // Test GET /api/users
  let res = http.get('http://localhost:3000/api/users');
  check(res, {
    'status is 200': (r) => r.status === 200,
    'response time < 500ms': (r) => r.timings.duration < 500
  });
  sleep(1);

  // Test POST /api/users
  let createRes = http.post('http://localhost:3000/api/users', JSON.stringify({
    email: 'test-' + Date.now() + '@example.com',
    name: 'Test User',
    password: 'secure'
  }), {
    headers: { 'Content-Type': 'application/json' }
  });
  check(createRes, {
    'create status is 201': (r) => r.status === 201
  });
  sleep(1);
}
```

**load.js — Sustained load (RPS target, 5 min)**
```javascript
import http from 'k6/http';
import { check, sleep } from 'k6';

export const options = {
  stages: [
    { duration: '1m', target: 100 }, // Ramp up to 100 RPS
    { duration: '5m', target: 100 }, // Stay at 100 RPS
    { duration: '1m', target: 0 }    // Ramp down
  ],
  thresholds: {
    'http_req_duration': ['p(95)<500', 'p(99)<1000'],
    'http_errors': ['rate<0.01']
  }
};

export default function() {
  // Mix of requests weighted by frequency
  const rand = Math.random();
  
  if (rand < 0.7) {
    // 70% GET requests
    http.get('http://localhost:3000/api/users?limit=10');
  } else if (rand < 0.9) {
    // 20% POST requests
    http.post('http://localhost:3000/api/users', JSON.stringify({
      email: 'user-' + Date.now() + '@example.com',
      name: 'Test',
      password: 'secure'
    }), { headers: { 'Content-Type': 'application/json' } });
  } else {
    // 10% DELETE requests
    const userId = Math.floor(Math.random() * 1000);
    http.del(`http://localhost:3000/api/users/${userId}`);
  }
  
  sleep(1);
}
```

**stress.js — Double target load (2x RPS, 10 min)**
```javascript
import http from 'k6/http';

export const options = {
  stages: [
    { duration: '2m', target: 200 }, // 2x target RPS
    { duration: '10m', target: 200 },
    { duration: '2m', target: 0 }
  ],
  thresholds: {
    'http_req_duration': ['p(95)<1000'], // Looser threshold
    'http_errors': ['rate<0.05'] // Allow 5% errors (finding breaking point)
  }
};

// Same request mix as load.js
export default function() { /* ... */ }
```

**spike.js — Sudden surge (10x for 30s)**
```javascript
import http from 'k6/http';

export const options = {
  stages: [
    { duration: '5m', target: 100 },  // Normal load
    { duration: '30s', target: 1000 }, // Spike: 10x normal
    { duration: '5m', target: 100 }   // Back to normal
  ],
  thresholds: {
    'http_req_duration': ['p(95)<2000'], // Very loose
    'http_errors': ['rate<0.10'] // Expect errors
  }
};

export default function() { /* ... */ }
```

### Step 4: Generate Locust Scenarios (if tool is locust)

Create `load-tests/<service>/locustfile.py`:

```python
from locust import HttpUser, task, between
import random

class APIUser(HttpUser):
    wait_time = between(1, 3)
    
    @task(7)  # 70% weight
    def list_users(self):
        self.client.get('/api/users?limit=10')
    
    @task(2)  # 20% weight
    def create_user(self):
        self.client.post('/api/users', json={
            'email': f'user-{int(time.time()*1000)}@example.com',
            'name': 'Test User',
            'password': 'secure'
        })
    
    @task(1)  # 10% weight
    def delete_user(self):
        user_id = random.randint(1, 1000)
        self.client.delete(f'/api/users/{user_id}')

if __name__ == '__main__':
    import os
    os.system('locust -f locustfile.py --headless -u 100 -r 10 -t 5m')
```

### Step 5: Generate Configuration Files

Create `load-tests/<service>/thresholds.json`:

```json
{
  "smoke": {
    "vus": 1,
    "duration_seconds": 30,
    "p95_latency_ms": 500,
    "p99_latency_ms": 1000,
    "error_rate_percent": 1
  },
  "load": {
    "vus": 100,
    "duration_seconds": 420,
    "p95_latency_ms": 500,
    "p99_latency_ms": 1000,
    "error_rate_percent": 1
  },
  "stress": {
    "vus": 200,
    "duration_seconds": 600,
    "p95_latency_ms": 1000,
    "p99_latency_ms": 2000,
    "error_rate_percent": 5
  },
  "spike": {
    "vus": 1000,
    "duration_seconds": 30,
    "p95_latency_ms": 2000,
    "p99_latency_ms": 5000,
    "error_rate_percent": 10
  }
}
```

Create `load-tests/<service>/config.json`:

```json
{
  "service": "api-server",
  "endpoint": "http://localhost:3000",
  "endpoints": [
    "GET /api/users",
    "POST /api/users",
    "GET /api/users/{id}",
    "DELETE /api/users/{id}"
  ],
  "authentication": "none",
  "tool": "k6"
}
```

### Step 6: Generate Orchestration Script

Create `load-tests/run.sh`:

```bash
#!/bin/bash

set -e

SCENARIO=${1:-smoke}  # Default: smoke test
SERVICE=${2:-all}    # Default: all services

echo "=== Load Testing: $SCENARIO scenario ==="

if [ "$SERVICE" = "all" ] || [ "$SERVICE" = "api-server" ]; then
  echo "Testing api-server..."
  k6 run load-tests/api-server/scenarios/$SCENARIO.js \
    --out json=load-tests/api-server/results-$SCENARIO.json
fi

if [ "$SERVICE" = "all" ] || [ "$SERVICE" = "worker" ]; then
  echo "Testing worker..."
  k6 run load-tests/worker/scenarios/$SCENARIO.js \
    --out json=load-tests/worker/results-$SCENARIO.json
fi

echo "=== Results ==="
echo "Smoke test: load-tests/api-server/results-smoke.json"
echo ""
echo "To view results:"
echo "  cat load-tests/api-server/results-smoke.json | jq '.metrics'"
```

### Step 7: Generate Documentation

Create `load-tests/README.md`:

```markdown
# Load Testing

Load test scenarios for all APIs.

## Quick Start

```bash
# Run smoke test (quick validation)
./run.sh smoke api-server

# Run load test (sustained RPS)
./run.sh load api-server

# Run all scenarios
./run.sh smoke all
./run.sh load all
./run.sh stress all
./run.sh spike all
```

## Scenarios

- **smoke.js** — 1 VU, 30 seconds (baseline)
- **load.js** — Ramp to 100 RPS, sustain 5 minutes
- **stress.js** — 2x target RPS (200), 10 minutes (find limits)
- **spike.js** — 10x RPS (1000) for 30 seconds (test recovery)

## Thresholds

Targets by stage (see thresholds.json):
- **MVP**: p95 < 1s, error < 5%
- **Growth**: p95 < 500ms, error < 1%
- **Enterprise**: p95 < 200ms, error < 0.5%

## Results

Results are saved as JSON in each service's directory:
- `load-tests/api-server/results-smoke.json`
- `load-tests/api-server/results-load.json`

Parse with: `jq '.metrics' results.json`
```

## Error Handling

### Contract Cannot Be Parsed

If an OpenAPI schema is malformed:
- Log warning: `"contract_parse_failed_<service>"`
- Skip that service, continue with others
- Report: "Could not parse contract for [service]; skipped from load tests"

### No Endpoints Found in Contract

If contract has no paths (empty schema):
- Log warning: `"no_endpoints_found_<service>"`
- Generate minimal smoke test (just connection test)
- Continue

### Unsupported Request Body Type

If request body schema is too complex (nested recursive types):
- Use simple placeholder data
- Add TODO comment for manual update
- Continue

### Load Testing Tool Not Installed

If tool is specified but not available:
- For k6: report "Install with: `npm install -g k6` or `brew install k6`"
- For Locust: report "Install with: `pip install locust`"
- Still generate scripts (user can install later)

## Rules

- **Realistic traffic patterns**: Mix GET/POST/DELETE based on typical usage
- **Mock data generation**: Avoid hardcoded IDs; use dynamic generation
- **Stage-appropriate thresholds**: MVP lenient, Growth moderate, Enterprise strict
- **Runnable immediately**: `./run.sh smoke` should work without setup
- **Documentation included**: Comments in scripts explaining each scenario
- **All endpoints covered**: Smoke test touches all major endpoints
- **Thresholds should find problems**: Not just confirm baseline
- **Error handling graceful**: Spike/stress tests expect failures; thresholds reflect that
