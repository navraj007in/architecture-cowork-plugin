---
name: export-openapi
description: Generate OpenAPI 3.0 specification from blueprint API documentation. Creates interactive API docs that can be imported into Postman, Swagger UI, and other API testing tools.
---

# OpenAPI Specification Generator

Convert your architecture blueprint's **API specification** into an **OpenAPI 3.0 document** for interactive API documentation and testing.

**Perfect for**: API documentation, frontend/mobile dev handoff, API testing, client SDK generation

---

## When to Use This Skill

Use this skill when you need to:
- Share API specifications with frontend/mobile developers
- Generate interactive API documentation (Swagger UI)
- Import API into Postman for testing
- Generate client SDKs automatically
- Validate API responses against spec
- Create API mocks for parallel development
- Document APIs for third-party integrators

**Input**: Architecture blueprint (Section 6: API Specification)
**Output**: `openapi.yaml` (OpenAPI 3.0 spec)

---

## What's Generated

### 1. OpenAPI Specification File

**openapi.yaml**:
```yaml
openapi: 3.0.3
info:
  title: Acme Ticketing API
  description: Customer support ticketing platform API
  version: 1.0.0
  contact:
    name: API Support
    email: api@acme.com
  license:
    name: MIT

servers:
  - url: https://api.acme.com/v1
    description: Production
  - url: https://staging-api.acme.com/v1
    description: Staging
  - url: http://localhost:3000/v1
    description: Local Development

tags:
  - name: Authentication
    description: User authentication and authorization
  - name: Tickets
    description: Ticket management operations
  - name: Users
    description: User management operations
  - name: Workspaces
    description: Workspace/tenant management

paths:
  /auth/signup:
    post:
      summary: Create new user account
      description: Register a new user and create their workspace
      operationId: createUser
      tags:
        - Authentication
      requestBody:
        required: true
        content:
          application/json:
            schema:
              $ref: '#/components/schemas/SignupRequest'
            examples:
              basic:
                value:
                  email: user@example.com
                  password: SecurePass123!
                  workspaceName: Acme Corp
      responses:
        '201':
          description: User created successfully
          content:
            application/json:
              schema:
                $ref: '#/components/schemas/AuthResponse'
              examples:
                success:
                  value:
                    user:
                      id: usr_abc123
                      email: user@example.com
                      workspaceId: ws_xyz789
                    accessToken: eyJhbGc...
                    refreshToken: eyJhbGc...
        '400':
          $ref: '#/components/responses/BadRequest'
        '409':
          description: Email already exists
          content:
            application/json:
              schema:
                $ref: '#/components/schemas/Error'
              examples:
                duplicate:
                  value:
                    error: email_exists
                    message: Email already registered
        '429':
          $ref: '#/components/responses/RateLimitExceeded'

  /tickets:
    get:
      summary: List tickets
      description: Retrieve tickets for current workspace with filtering and pagination
      operationId: listTickets
      tags:
        - Tickets
      security:
        - bearerAuth: []
      parameters:
        - name: status
          in: query
          schema:
            type: string
            enum: [OPEN, IN_PROGRESS, RESOLVED, CLOSED]
          description: Filter by ticket status
        - name: assigneeId
          in: query
          schema:
            type: string
          description: Filter by assigned user ID
        - name: page
          in: query
          schema:
            type: integer
            minimum: 1
            default: 1
          description: Page number
        - name: limit
          in: query
          schema:
            type: integer
            minimum: 1
            maximum: 100
            default: 20
          description: Items per page
        - name: sort
          in: query
          schema:
            type: string
            enum: [createdAt, updatedAt, priority]
            default: createdAt
          description: Sort field
        - name: order
          in: query
          schema:
            type: string
            enum: [asc, desc]
            default: desc
          description: Sort order
      responses:
        '200':
          description: Tickets retrieved successfully
          content:
            application/json:
              schema:
                type: object
                properties:
                  data:
                    type: array
                    items:
                      $ref: '#/components/schemas/Ticket'
                  pagination:
                    $ref: '#/components/schemas/Pagination'
        '401':
          $ref: '#/components/responses/Unauthorized'
        '403':
          $ref: '#/components/responses/Forbidden'

    post:
      summary: Create ticket
      description: Create a new support ticket
      operationId: createTicket
      tags:
        - Tickets
      security:
        - bearerAuth: []
      requestBody:
        required: true
        content:
          application/json:
            schema:
              $ref: '#/components/schemas/CreateTicketRequest'
      responses:
        '201':
          description: Ticket created successfully
          content:
            application/json:
              schema:
                $ref: '#/components/schemas/Ticket'
        '400':
          $ref: '#/components/responses/BadRequest'
        '401':
          $ref: '#/components/responses/Unauthorized'

components:
  securitySchemes:
    bearerAuth:
      type: http
      scheme: bearer
      bearerFormat: JWT
      description: JWT token from /auth/login or /auth/signup

  schemas:
    SignupRequest:
      type: object
      required:
        - email
        - password
        - workspaceName
      properties:
        email:
          type: string
          format: email
          example: user@example.com
        password:
          type: string
          format: password
          minLength: 8
          example: SecurePass123!
        workspaceName:
          type: string
          minLength: 1
          maxLength: 100
          example: Acme Corp

    AuthResponse:
      type: object
      properties:
        user:
          $ref: '#/components/schemas/User'
        accessToken:
          type: string
          description: JWT access token (expires in 15 minutes)
        refreshToken:
          type: string
          description: Refresh token (expires in 30 days)

    User:
      type: object
      properties:
        id:
          type: string
          example: usr_abc123
        email:
          type: string
          format: email
        name:
          type: string
          nullable: true
        role:
          type: string
          enum: [ADMIN, AGENT, VIEWER]
        workspaceId:
          type: string
        createdAt:
          type: string
          format: date-time
        updatedAt:
          type: string
          format: date-time

    Ticket:
      type: object
      properties:
        id:
          type: string
          example: tkt_xyz789
        workspaceId:
          type: string
        title:
          type: string
        description:
          type: string
        status:
          type: string
          enum: [OPEN, IN_PROGRESS, RESOLVED, CLOSED]
        priority:
          type: string
          enum: [LOW, MEDIUM, HIGH, URGENT]
        assigneeId:
          type: string
          nullable: true
        createdBy:
          type: string
        createdAt:
          type: string
          format: date-time
        updatedAt:
          type: string
          format: date-time

    CreateTicketRequest:
      type: object
      required:
        - title
        - description
      properties:
        title:
          type: string
          minLength: 1
          maxLength: 200
        description:
          type: string
          minLength: 1
        priority:
          type: string
          enum: [LOW, MEDIUM, HIGH, URGENT]
          default: MEDIUM
        assigneeId:
          type: string
          nullable: true

    Pagination:
      type: object
      properties:
        page:
          type: integer
        limit:
          type: integer
        total:
          type: integer
        totalPages:
          type: integer

    Error:
      type: object
      properties:
        error:
          type: string
          description: Error code
        message:
          type: string
          description: Human-readable error message
        details:
          type: object
          nullable: true
          description: Additional error details

  responses:
    BadRequest:
      description: Invalid request parameters
      content:
        application/json:
          schema:
            $ref: '#/components/schemas/Error'
          examples:
            validation:
              value:
                error: validation_error
                message: Invalid request parameters
                details:
                  email: Invalid email format

    Unauthorized:
      description: Authentication required
      content:
        application/json:
          schema:
            $ref: '#/components/schemas/Error'
          examples:
            missing_token:
              value:
                error: unauthorized
                message: Authentication token required

    Forbidden:
      description: Insufficient permissions
      content:
        application/json:
          schema:
            $ref: '#/components/schemas/Error'
          examples:
            access_denied:
              value:
                error: forbidden
                message: Insufficient permissions to access this resource

    RateLimitExceeded:
      description: Rate limit exceeded
      content:
        application/json:
          schema:
            $ref: '#/components/schemas/Error'
          examples:
            rate_limit:
              value:
                error: rate_limit_exceeded
                message: Too many requests, please try again later
      headers:
        X-RateLimit-Limit:
          schema:
            type: integer
          description: Request limit per window
        X-RateLimit-Remaining:
          schema:
            type: integer
          description: Requests remaining in current window
        X-RateLimit-Reset:
          schema:
            type: integer
          description: Unix timestamp when rate limit resets
```

---

## How It Works

### Step 1: Parse API Specification from Blueprint

Extract from **Section 6: API Specification**:

```markdown
## API Specification

### Endpoints

#### POST /auth/signup
**Description**: Create new user account and workspace

**Authentication**: None (public endpoint)

**Request**:
```json
{
  "email": "user@example.com",
  "password": "SecurePass123!",
  "workspaceName": "Acme Corp"
}
```

**Response** (201 Created):
```json
{
  "user": {
    "id": "usr_abc123",
    "email": "user@example.com",
    "workspaceId": "ws_xyz789"
  },
  "accessToken": "eyJhbGc...",
  "refreshToken": "eyJhbGc..."
}
```

**Errors**:
- 400: Invalid request (validation errors)
- 409: Email already exists
- 429: Rate limit exceeded (max 5 signups/hour per IP)

---

#### GET /tickets
**Description**: List tickets for current workspace

**Authentication**: Required (Bearer token)

**Query Parameters**:
- `status` (optional): Filter by status (OPEN, IN_PROGRESS, RESOLVED, CLOSED)
- `assigneeId` (optional): Filter by assigned user
- `page` (optional, default: 1): Page number
- `limit` (optional, default: 20, max: 100): Items per page
- `sort` (optional, default: createdAt): Sort field
- `order` (optional, default: desc): Sort order (asc, desc)

**Response** (200 OK):
```json
{
  "data": [
    {
      "id": "tkt_xyz789",
      "title": "Cannot login to app",
      "description": "Users report login button is broken",
      "status": "OPEN",
      "priority": "HIGH",
      "assigneeId": "usr_abc123",
      "createdBy": "usr_def456",
      "createdAt": "2026-02-07T10:00:00Z",
      "updatedAt": "2026-02-07T10:00:00Z"
    }
  ],
  "pagination": {
    "page": 1,
    "limit": 20,
    "total": 47,
    "totalPages": 3
  }
}
```

**Errors**:
- 401: Unauthorized (missing or invalid token)
- 403: Forbidden (insufficient permissions)
```

### Step 2: Extract API Metadata

From blueprint sections:

**Info**:
- **Title**: From Section 1 (Executive Summary)
- **Description**: From product description
- **Version**: 1.0.0 (default)
- **Contact**: Placeholder or from user input

**Servers**:
- **Production**: From deployment section (Section 9)
- **Staging**: Inferred from production URL
- **Local**: http://localhost:3000 (default for dev)

**Security**:
- **Bearer JWT**: If Clerk/Auth0 detected
- **API Key**: If API key auth mentioned
- **OAuth2**: If OAuth flows described

### Step 3: Convert Endpoints to OpenAPI Paths

For each endpoint:

1. **Parse HTTP method and path**: `POST /auth/signup`
2. **Extract request schema**: From request JSON example
3. **Extract response schemas**: From response examples
4. **Extract parameters**: Query, path, header params
5. **Extract error responses**: 400, 401, 403, 404, 500, etc.
6. **Add tags**: Group by feature area (Auth, Tickets, Users)

**Type inference from examples**:
```json
{
  "email": "user@example.com",  // → type: string, format: email
  "age": 25,                     // → type: integer
  "price": 19.99,                // → type: number, format: double
  "isActive": true,              // → type: boolean
  "createdAt": "2026-02-07T10:00:00Z"  // → type: string, format: date-time
}
```

### Step 4: Generate Reusable Components

Create schemas for common types:

**Request/Response objects**:
- SignupRequest
- LoginRequest
- CreateTicketRequest
- UpdateTicketRequest

**Domain models**:
- User
- Ticket
- Comment
- Workspace

**Common responses**:
- Error
- Pagination
- Success

**Reuse via $ref**:
```yaml
requestBody:
  content:
    application/json:
      schema:
        $ref: '#/components/schemas/SignupRequest'
```

### Step 5: Add Security Schemes

Based on authentication method detected:

**JWT (Clerk, Auth0)**:
```yaml
components:
  securitySchemes:
    bearerAuth:
      type: http
      scheme: bearer
      bearerFormat: JWT
```

**API Key (custom)**:
```yaml
components:
  securitySchemes:
    apiKey:
      type: apiKey
      in: header
      name: X-API-Key
```

**OAuth2 (third-party integrations)**:
```yaml
components:
  securitySchemes:
    oauth2:
      type: oauth2
      flows:
        authorizationCode:
          authorizationUrl: https://auth.acme.com/oauth/authorize
          tokenUrl: https://auth.acme.com/oauth/token
          scopes:
            read:tickets: Read tickets
            write:tickets: Create and update tickets
```

### Step 6: Add Examples and Descriptions

For each endpoint:
- **Summary**: One-line description
- **Description**: Detailed explanation
- **Request examples**: Valid request bodies
- **Response examples**: Success and error cases
- **Parameter descriptions**: What each param does

**Example**:
```yaml
parameters:
  - name: limit
    in: query
    description: Maximum number of items to return (1-100)
    schema:
      type: integer
      minimum: 1
      maximum: 100
      default: 20
    examples:
      small_page:
        value: 10
        summary: Small page size
      large_page:
        value: 100
        summary: Maximum page size
```

---

## Output Format

When invoked, generate:

```
📄 Generating OpenAPI specification from blueprint...

✅ Parsed API specification (Section 6)
✅ Detected 23 endpoints across 4 resource types
   - Authentication: 4 endpoints
   - Tickets: 7 endpoints
   - Users: 5 endpoints
   - Workspaces: 3 endpoints
   - Comments: 4 endpoints

✅ Inferred 18 request/response schemas
✅ Detected authentication: Bearer JWT (Clerk)
✅ Detected rate limiting: 60 requests/minute
✅ Added 3 server environments (prod, staging, local)

📄 Created openapi.yaml (847 lines)
📄 Created openapi.json (JSON format)

🚀 View interactive docs:
- Swagger UI: https://editor.swagger.io/ (paste openapi.yaml)
- Redoc: https://redocly.github.io/redoc/ (paste openapi.yaml)

📦 Import into tools:
- Postman: Import → OpenAPI 3.0 → openapi.yaml
- Insomnia: Import → openapi.yaml
- Stoplight: Import OpenAPI
- Paw: Import OpenAPI

🛠️  Generate client SDKs:
- TypeScript: npx @openapitools/openapi-generator-cli generate -i openapi.yaml -g typescript-fetch
- Python: openapi-generator-cli generate -i openapi.yaml -g python
- Go: openapi-generator-cli generate -i openapi.yaml -g go
- Swift: openapi-generator-cli generate -i openapi.yaml -g swift5

Next steps:
1. Review openapi.yaml for accuracy
2. Import into Postman for API testing
3. Generate client SDK for frontend
4. Host Swagger UI for team documentation
```

---

## Features

### 1. Interactive Documentation

**Swagger UI**:
- Browse all endpoints
- Try API calls directly from browser
- See request/response examples
- Test authentication

**Redoc**:
- Clean, readable documentation
- Three-panel layout
- Markdown support in descriptions
- Download OpenAPI spec

### 2. API Mocking

Use OpenAPI spec to generate mock servers:

**Prism (recommended)**:
```bash
npm install -g @stoplight/prism-cli

# Start mock server
prism mock openapi.yaml

# Mock server running at http://127.0.0.1:4010
# Returns example responses from spec
```

**Benefits**:
- Frontend can develop in parallel
- No backend dependencies
- Realistic example data
- Validates requests against schema

### 3. Client SDK Generation

**TypeScript**:
```bash
npx @openapitools/openapi-generator-cli generate \
  -i openapi.yaml \
  -g typescript-fetch \
  -o ./generated/api-client

# Generated: Type-safe API client
import { TicketsApi } from './generated/api-client';

const api = new TicketsApi({ basePath: 'https://api.acme.com' });
const tickets = await api.listTickets({ status: 'OPEN' });
```

**Python**:
```bash
openapi-generator-cli generate \
  -i openapi.yaml \
  -g python \
  -o ./api-client

# Generated: Python client
from api_client import TicketsApi

api = TicketsApi()
tickets = api.list_tickets(status='OPEN')
```

### 4. Request/Response Validation

**Express.js middleware**:
```typescript
import { validateRequest } from 'express-openapi-validator';

app.use(validateRequest({
  apiSpec: './openapi.yaml',
  validateRequests: true,
  validateResponses: true,
}));

// Automatically validates all requests/responses against spec
// Returns 400 if request doesn't match schema
```

### 5. Postman Collection Generation

Automatically create Postman collection:

```bash
# Convert OpenAPI to Postman Collection
npx openapi-to-postmanv2 \
  -s openapi.yaml \
  -o postman-collection.json

# Import postman-collection.json into Postman
```

---

## Customization Options

**Optional parameters**:

1. **Output format**: YAML (default), JSON
2. **OpenAPI version**: 3.0.3 (default), 3.1.0
3. **Server URLs**: Custom production/staging URLs
4. **Contact info**: Email, support URL
5. **License**: MIT, Apache 2.0, Proprietary
6. **Security schemes**: Custom auth methods

**Examples**:

```bash
# JSON format
/architect:export-openapi --format=json

# Custom servers
/architect:export-openapi --prod-url=https://api.prod.acme.com

# Add contact info
/architect:export-openapi --contact-email=api@acme.com --contact-name="API Support"

# Custom license
/architect:export-openapi --license=Apache-2.0
```

---

## Advanced Features

### Webhooks (OpenAPI 3.1)

If webhooks mentioned in blueprint:

```yaml
webhooks:
  ticketCreated:
    post:
      summary: Ticket Created
      description: Triggered when a new ticket is created
      requestBody:
        content:
          application/json:
            schema:
              type: object
              properties:
                event:
                  type: string
                  enum: [ticket.created]
                data:
                  $ref: '#/components/schemas/Ticket'
      responses:
        '200':
          description: Webhook received successfully
```

### Pagination Links (HAL/HATEOAS)

Add pagination metadata:

```yaml
Pagination:
  type: object
  properties:
    page:
      type: integer
    limit:
      type: integer
    total:
      type: integer
    totalPages:
      type: integer
    links:
      type: object
      properties:
        self:
          type: string
          example: /tickets?page=2
        first:
          type: string
          example: /tickets?page=1
        prev:
          type: string
          nullable: true
          example: /tickets?page=1
        next:
          type: string
          nullable: true
          example: /tickets?page=3
        last:
          type: string
          example: /tickets?page=10
```

### Rate Limiting Headers

Document rate limit headers:

```yaml
headers:
  X-RateLimit-Limit:
    schema:
      type: integer
    description: Total requests allowed per window
    example: 60
  X-RateLimit-Remaining:
    schema:
      type: integer
    description: Requests remaining in current window
    example: 42
  X-RateLimit-Reset:
    schema:
      type: integer
    description: Unix timestamp when limit resets
    example: 1612742400
```

---

## Error Handling

### If API section missing from blueprint:
- **Action**: Error with guidance
- **Example**: "❌ No API specification found. Run `/architect:blueprint` first."

### If endpoints have incomplete schemas:
- **Action**: Infer schemas from examples, mark with warnings
- **Example**: "⚠️ Inferred schema for GET /tickets from example response"

### If authentication method unclear:
- **Action**: Default to Bearer JWT, prompt user to confirm
- **Options**: "1) Bearer JWT (recommended), 2) API Key, 3) OAuth2, 4) None"

---

## Integration with Other Tools

### Swagger UI (Local Hosting)

```bash
# Install Swagger UI
npm install swagger-ui-express

# Serve OpenAPI spec
node -e "
const swaggerUi = require('swagger-ui-express');
const YAML = require('yamljs');
const express = require('express');
const app = express();
const spec = YAML.load('./openapi.yaml');
app.use('/api-docs', swaggerUi.serve, swaggerUi.setup(spec));
app.listen(3001, () => console.log('Docs at http://localhost:3001/api-docs'));
"
```

### Stoplight Studio

**Visual OpenAPI editor**:
```bash
# Install Stoplight Studio
brew install stoplight/tap/studio

# Open spec
studio openapi.yaml

# Edit visually with GUI
```

---

## Success Criteria

A successful OpenAPI export should:
- ✅ Include all endpoints from blueprint
- ✅ Have valid OpenAPI 3.0 syntax (validates with openapi-lint)
- ✅ Include request/response schemas for all endpoints
- ✅ Document all query parameters, headers, path params
- ✅ Include authentication/authorization details
- ✅ Provide examples for requests and responses
- ✅ Group endpoints by tags (resource types)
- ✅ Document error responses (400, 401, 403, 404, 500)
- ✅ Be importable into Postman/Insomnia without errors
- ✅ Support client SDK generation

---

## Examples

### Example 1: Basic Export

```bash
/architect:export-openapi

# Output:
# ✅ Created openapi.yaml (847 lines)
# ✅ 23 endpoints documented
```

### Example 2: JSON Format

```bash
/architect:export-openapi --format=json

# Output:
# ✅ Created openapi.json
```

### Example 3: With Custom Servers

```bash
/architect:export-openapi \
  --prod-url=https://api.acme.com/v1 \
  --staging-url=https://staging-api.acme.com/v1

# Output:
# ✅ Added 3 server environments
```

### Example 4: Generate and Host Docs

```bash
/architect:export-openapi
npx swagger-ui-express openapi.yaml --port 3001

# Docs available at: http://localhost:3001
```
