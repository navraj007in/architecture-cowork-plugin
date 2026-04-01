---
name: project-templates-nestjs
description: Starter file templates and boilerplate for scaffolding NestJS backend services (modules, DI, guards, Swagger, validation)
type: skill-extension
parent: project-templates
---

# NestJS Project Templates

## Backend — NestJS

**Initialization (preferred):**
```bash
npx @nestjs/cli new . --package-manager npm --skip-git
```

If CLI is unavailable, create files manually using the templates below.

---

**package.json:**
```json
{
  "name": "{{component-name}}",
  "version": "0.1.0",
  "private": true,
  "scripts": {
    "build": "nest build",
    "start": "node dist/main",
    "start:dev": "nest start --watch",
    "start:debug": "nest start --debug --watch",
    "lint": "eslint \"{src,apps,libs,test}/**/*.ts\"",
    "test": "jest",
    "test:e2e": "jest --config ./test/jest-e2e.json"
  },
  "dependencies": {
    "@nestjs/common": "^10.0.0",
    "@nestjs/core": "^10.0.0",
    "@nestjs/platform-express": "^10.0.0",
    "@nestjs/config": "^3.0.0",
    "@nestjs/swagger": "^7.0.0",
    "@nestjs/terminus": "^10.0.0",
    "class-validator": "^0.14.0",
    "class-transformer": "^0.5.0",
    "helmet": "^7.0.0",
    "reflect-metadata": "^0.1.13",
    "rxjs": "^7.8.0"
  },
  "devDependencies": {
    "@nestjs/cli": "^10.0.0",
    "@nestjs/schematics": "^10.0.0",
    "@nestjs/testing": "^10.0.0",
    "@types/express": "^4.17.0",
    "@types/jest": "^29.5.0",
    "@types/node": "^20.0.0",
    "typescript": "^5.1.0",
    "jest": "^29.5.0",
    "ts-jest": "^29.1.0"
  }
}
```

**tsconfig.json:**
```json
{
  "compilerOptions": {
    "module": "commonjs",
    "declaration": true,
    "removeComments": true,
    "emitDecoratorMetadata": true,
    "experimentalDecorators": true,
    "allowSyntheticDefaultImports": true,
    "target": "ES2021",
    "sourceMap": true,
    "outDir": "./dist",
    "baseUrl": "./",
    "strict": true,
    "skipLibCheck": true,
    "strictNullChecks": true,
    "noImplicitAny": true,
    "strictBindCallApply": true,
    "forceConsistentCasingInFileNames": true,
    "noFallthroughCasesInSwitch": true
  }
}
```

**src/main.ts:**
```ts
import { NestFactory } from '@nestjs/core';
import { ValidationPipe, Logger } from '@nestjs/common';
import { SwaggerModule, DocumentBuilder } from '@nestjs/swagger';
import helmet from 'helmet';
import { AppModule } from './app.module';

async function bootstrap() {
  const app = await NestFactory.create(AppModule, {
    logger: ['error', 'warn', 'log'],
  });

  // Security
  app.use(helmet());
  app.enableCors({
    origin: process.env.ALLOWED_ORIGINS?.split(',') ?? [],
    credentials: true,
  });

  // Validation — transform payloads to class instances, strip unknown props
  app.useGlobalPipes(
    new ValidationPipe({
      transform: true,
      whitelist: true,
      forbidNonWhitelisted: true,
    }),
  );

  // Swagger
  const config = new DocumentBuilder()
    .setTitle('{{component-name}}')
    .setDescription('API documentation')
    .setVersion('0.1.0')
    .addBearerAuth()
    .build();
  const document = SwaggerModule.createDocument(app, config);
  SwaggerModule.setup('docs', app, document);

  // Graceful shutdown
  app.enableShutdownHooks();

  const port = process.env.PORT ?? 3000;
  await app.listen(port);
  Logger.log(`Server running on http://localhost:${port}`, 'Bootstrap');
  Logger.log(`Docs: http://localhost:${port}/docs`, 'Bootstrap');
}
bootstrap();
```

**src/app.module.ts:**
```ts
import { Module } from '@nestjs/common';
import { ConfigModule } from '@nestjs/config';
import { TerminusModule } from '@nestjs/terminus';
import { HealthController } from './health/health.controller';

@Module({
  imports: [
    ConfigModule.forRoot({ isGlobal: true }),
    TerminusModule,
    // TODO: import feature modules here
  ],
  controllers: [HealthController],
})
export class AppModule {}
```

**src/health/health.controller.ts:**
```ts
import { Controller, Get } from '@nestjs/common';
import { HealthCheck, HealthCheckService, HttpHealthIndicator } from '@nestjs/terminus';
import { ApiTags } from '@nestjs/swagger';

@ApiTags('health')
@Controller('health')
export class HealthController {
  constructor(private health: HealthCheckService) {}

  @Get()
  @HealthCheck()
  check() {
    return this.health.check([
      // TODO: add DB indicator — new TypeOrmHealthIndicator() or PrismaHealthIndicator
    ]);
  }
}
```

**src/common/middleware/correlation-id.middleware.ts:**
```ts
import { Injectable, NestMiddleware } from '@nestjs/common';
import { Request, Response, NextFunction } from 'express';
import { randomUUID } from 'crypto';

@Injectable()
export class CorrelationIdMiddleware implements NestMiddleware {
  use(req: Request, res: Response, next: NextFunction) {
    const id = (req.headers['x-correlation-id'] as string) ?? randomUUID();
    req.headers['x-correlation-id'] = id;
    res.setHeader('x-correlation-id', id);
    next();
  }
}
```

**src/common/guards/auth.guard.ts:**
```ts
import { Injectable, CanActivate, ExecutionContext, UnauthorizedException } from '@nestjs/common';
import { Observable } from 'rxjs';

// TODO: Replace stub with actual JWT verification (Clerk, Auth0, Cognito, etc.)
@Injectable()
export class AuthGuard implements CanActivate {
  canActivate(context: ExecutionContext): boolean | Promise<boolean> | Observable<boolean> {
    const request = context.switchToHttp().getRequest();
    const authHeader: string = request.headers['authorization'] ?? '';
    if (!authHeader.startsWith('Bearer ')) {
      throw new UnauthorizedException('Missing or invalid Authorization header');
    }
    // const token = authHeader.replace('Bearer ', '');
    // TODO: verify token, attach user to request
    return true;
  }
}
```

**Feature module structure** (per responsibility from manifest):
```
src/
  {{responsibility}}/
    {{responsibility}}.module.ts      — @Module({ controllers, providers })
    {{responsibility}}.controller.ts  — @Controller, @Get, @Post, @Put, @Delete with Swagger decorators
    {{responsibility}}.service.ts     — @Injectable business logic
    dto/
      create-{{responsibility}}.dto.ts  — class with class-validator decorators
      update-{{responsibility}}.dto.ts
    entities/
      {{responsibility}}.entity.ts    — TypeORM/Prisma entity stub
```

**Directory structure:**
```
{{component-name}}/
├── src/
│   ├── main.ts
│   ├── app.module.ts
│   ├── health/
│   │   └── health.controller.ts
│   └── common/
│       ├── guards/auth.guard.ts
│       └── middleware/correlation-id.middleware.ts
├── test/
│   └── app.e2e-spec.ts
├── package.json
├── tsconfig.json
├── .env.example
├── Dockerfile
├── docker-compose.yml
└── .github/workflows/ci.yml
```

---

## NestJS — Dockerfile

```dockerfile
# Build stage
FROM node:20-alpine AS builder
WORKDIR /app
COPY package*.json ./
RUN npm ci
COPY . .
RUN npm run build

# Production stage
FROM node:20-alpine
WORKDIR /app
ENV NODE_ENV=production
COPY package*.json ./
RUN npm ci --omit=dev && npm cache clean --force
COPY --from=builder /app/dist ./dist
EXPOSE 3000
HEALTHCHECK --interval=30s --timeout=5s --start-period=15s --retries=3 \
  CMD wget -qO- http://localhost:3000/health || exit 1
USER node
CMD ["node", "dist/main"]
```

---

## NestJS — docker-compose.yml

```yaml
services:
  {{component-name}}:
    build: .
    ports:
      - "${PORT:-3000}:3000"
    env_file: .env
    depends_on:
      db:
        condition: service_healthy

  db:
    image: postgres:16-alpine
    environment:
      POSTGRES_DB: ${DB_NAME:-{{component-name}}_dev}
      POSTGRES_USER: ${DB_USER:-postgres}
      POSTGRES_PASSWORD: ${DB_PASSWORD:-postgres}
    ports:
      - "${DB_PORT:-5432}:5432"
    volumes:
      - db_data:/var/lib/postgresql/data
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U postgres"]
      interval: 5s
      timeout: 5s
      retries: 5

volumes:
  db_data:
```

---

## NestJS — .env.example

```bash
PORT=3000
NODE_ENV=development

DATABASE_URL=postgres://postgres:postgres@localhost:5432/{{component-name}}_dev

ALLOWED_ORIGINS=http://localhost:3100

# Auth provider — replace with actual values
AUTH_AUTHORITY=https://your-auth-provider/.well-known/jwks.json
AUTH_AUDIENCE={{component-name}}

# SENTRY_DSN=                # TODO (growth): add error tracking
# REDIS_URL=                 # TODO (growth): add caching/queues

# STAGING DATABASE_URL=...
# PRODUCTION DATABASE_URL=...
```

---

## NestJS — CI Workflow

**.github/workflows/ci.yml:**
```yaml
name: CI

on:
  push:
    branches: [main]
  pull_request:
    branches: [main]

jobs:
  ci:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - uses: actions/setup-node@v4
        with:
          node-version: 20
          cache: npm

      - run: npm ci

      - name: Lint
        run: npm run lint

      - name: Build
        run: npm run build

      - name: Test
        run: npm test -- --passWithNoTests
```
