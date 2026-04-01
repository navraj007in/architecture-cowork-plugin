---
name: project-templates-spring-boot
description: Starter file templates and boilerplate for scaffolding Java Spring Boot backend services (Maven, Spring Security, Spring Data JPA, Actuator)
type: skill-extension
parent: project-templates
---

# Spring Boot Project Templates

## Backend — Java / Spring Boot

**Initialization (preferred):**
```bash
# Requires Spring Boot CLI or curl to start.spring.io
curl https://start.spring.io/starter.tgz \
  -d type=maven-project \
  -d language=java \
  -d bootVersion=3.3.0 \
  -d groupId=com.{{org}} \
  -d artifactId={{component-name}} \
  -d name={{component-name}} \
  -d packageName=com.{{org}}.{{component-name-camel}} \
  -d dependencies=web,data-jpa,security,actuator,validation,postgresql,lombok \
  -d javaVersion=21 \
  | tar -xzvf -
```

If CLI/curl is unavailable, create `pom.xml` and source files manually using the templates below.

---

**pom.xml:**
```xml
<?xml version="1.0" encoding="UTF-8"?>
<project xmlns="http://maven.apache.org/POM/4.0.0"
         xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
         xsi:schemaLocation="http://maven.apache.org/POM/4.0.0 https://maven.apache.org/xsd/maven-4.0.0.xsd">
  <modelVersion>4.0.0</modelVersion>

  <parent>
    <groupId>org.springframework.boot</groupId>
    <artifactId>spring-boot-starter-parent</artifactId>
    <version>3.3.0</version>
    <relativePath/>
  </parent>

  <groupId>com.{{org}}</groupId>
  <artifactId>{{component-name}}</artifactId>
  <version>0.0.1-SNAPSHOT</version>
  <name>{{component-name}}</name>
  <description>{{component-description}}</description>

  <properties>
    <java.version>21</java.version>
  </properties>

  <dependencies>
    <dependency>
      <groupId>org.springframework.boot</groupId>
      <artifactId>spring-boot-starter-web</artifactId>
    </dependency>
    <dependency>
      <groupId>org.springframework.boot</groupId>
      <artifactId>spring-boot-starter-data-jpa</artifactId>
    </dependency>
    <dependency>
      <groupId>org.springframework.boot</groupId>
      <artifactId>spring-boot-starter-security</artifactId>
    </dependency>
    <dependency>
      <groupId>org.springframework.boot</groupId>
      <artifactId>spring-boot-starter-actuator</artifactId>
    </dependency>
    <dependency>
      <groupId>org.springframework.boot</groupId>
      <artifactId>spring-boot-starter-validation</artifactId>
    </dependency>
    <dependency>
      <groupId>org.postgresql</groupId>
      <artifactId>postgresql</artifactId>
      <scope>runtime</scope>
    </dependency>
    <dependency>
      <groupId>org.projectlombok</groupId>
      <artifactId>lombok</artifactId>
      <optional>true</optional>
    </dependency>
    <dependency>
      <groupId>org.springdoc</groupId>
      <artifactId>springdoc-openapi-starter-webmvc-ui</artifactId>
      <version>2.5.0</version>
    </dependency>

    <!-- Test -->
    <dependency>
      <groupId>org.springframework.boot</groupId>
      <artifactId>spring-boot-starter-test</artifactId>
      <scope>test</scope>
    </dependency>
    <dependency>
      <groupId>org.springframework.security</groupId>
      <artifactId>spring-security-test</artifactId>
      <scope>test</scope>
    </dependency>
  </dependencies>

  <build>
    <plugins>
      <plugin>
        <groupId>org.springframework.boot</groupId>
        <artifactId>spring-boot-maven-plugin</artifactId>
        <configuration>
          <excludes>
            <exclude>
              <groupId>org.projectlombok</groupId>
              <artifactId>lombok</artifactId>
            </exclude>
          </excludes>
        </configuration>
      </plugin>
    </plugins>
  </build>
</project>
```

---

**src/main/resources/application.yml:**
```yaml
spring:
  application:
    name: {{component-name}}
  datasource:
    url: ${DATABASE_URL}
    driver-class-name: org.postgresql.Driver
  jpa:
    hibernate:
      ddl-auto: validate
    show-sql: false
    open-in-view: false
  security:
    oauth2:
      resourceserver:
        jwt:
          issuer-uri: ${AUTH_ISSUER_URI}

server:
  port: ${PORT:8080}
  shutdown: graceful

management:
  endpoints:
    web:
      exposure:
        include: health,info,metrics
  endpoint:
    health:
      show-details: when-authorized
  health:
    livenessstate:
      enabled: true
    readinessstate:
      enabled: true

springdoc:
  api-docs:
    path: /v3/api-docs
  swagger-ui:
    path: /docs

logging:
  pattern:
    console: "%d{yyyy-MM-dd HH:mm:ss} [%thread] %-5level %logger{36} - %msg%n"
  level:
    root: INFO
    com.{{org}}: DEBUG
```

---

**Application entry point:**

`src/main/java/com/{{org}}/{{component-name-camel}}/Application.java`:
```java
package com.{{org}}.{{componentNameCamel}};

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;

@SpringBootApplication
public class Application {
    public static void main(String[] args) {
        SpringApplication.run(Application.class, args);
    }
}
```

---

**Security config stub:**

`src/main/java/com/{{org}}/{{component-name-camel}}/config/SecurityConfig.java`:
```java
package com.{{org}}.{{componentNameCamel}}.config;

import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.security.config.annotation.web.builders.HttpSecurity;
import org.springframework.security.config.annotation.web.configuration.EnableWebSecurity;
import org.springframework.security.config.http.SessionCreationPolicy;
import org.springframework.security.web.SecurityFilterChain;

@Configuration
@EnableWebSecurity
public class SecurityConfig {

    @Bean
    public SecurityFilterChain filterChain(HttpSecurity http) throws Exception {
        return http
            .csrf(csrf -> csrf.disable())
            .sessionManagement(s -> s.sessionCreationPolicy(SessionCreationPolicy.STATELESS))
            .authorizeHttpRequests(auth -> auth
                .requestMatchers("/actuator/health/**", "/docs/**", "/v3/api-docs/**").permitAll()
                // TODO: configure per-path access rules per SDL personas
                .anyRequest().authenticated()
            )
            // TODO: replace with actual auth provider — e.g. OAuth2 resource server with JWT
            // .oauth2ResourceServer(oauth2 -> oauth2.jwt(Customizer.withDefaults()))
            .build();
    }
}
```

---

**Correlation ID filter:**

`src/main/java/com/{{org}}/{{component-name-camel}}/config/CorrelationIdFilter.java`:
```java
package com.{{org}}.{{componentNameCamel}}.config;

import jakarta.servlet.*;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import org.slf4j.MDC;
import org.springframework.core.annotation.Order;
import org.springframework.stereotype.Component;
import java.io.IOException;
import java.util.UUID;

@Component
@Order(1)
public class CorrelationIdFilter implements Filter {

    private static final String CORRELATION_HEADER = "X-Correlation-ID";

    @Override
    public void doFilter(ServletRequest req, ServletResponse res, FilterChain chain)
            throws IOException, ServletException {
        HttpServletRequest request = (HttpServletRequest) req;
        HttpServletResponse response = (HttpServletResponse) res;

        String correlationId = request.getHeader(CORRELATION_HEADER);
        if (correlationId == null || correlationId.isBlank()) {
            correlationId = UUID.randomUUID().toString();
        }
        MDC.put("correlationId", correlationId);
        response.setHeader(CORRELATION_HEADER, correlationId);
        try {
            chain.doFilter(req, res);
        } finally {
            MDC.remove("correlationId");
        }
    }
}
```

---

**Feature layer structure** (per responsibility from manifest):
```
src/main/java/com/{{org}}/{{component-name-camel}}/
  {{responsibility}}/
    {{Responsibility}}Controller.java   — @RestController, @RequestMapping, Swagger annotations
    {{Responsibility}}Service.java      — @Service, business logic
    {{Responsibility}}Repository.java   — @Repository extends JpaRepository<Entity, UUID>
    {{Responsibility}}.java             — @Entity, @Table, @Column (Lombok @Data/@Builder)
    dto/
      Create{{Responsibility}}Request.java  — Jakarta Bean Validation annotations
      {{Responsibility}}Response.java
```

**Directory structure:**
```
{{component-name}}/
├── src/
│   ├── main/
│   │   ├── java/com/{{org}}/{{component-name-camel}}/
│   │   │   ├── Application.java
│   │   │   ├── config/
│   │   │   │   ├── SecurityConfig.java
│   │   │   │   └── CorrelationIdFilter.java
│   │   │   └── (feature packages per responsibility)
│   │   └── resources/
│   │       ├── application.yml
│   │       └── application-test.yml
│   └── test/
│       └── java/com/{{org}}/{{component-name-camel}}/
│           └── ApplicationTests.java
├── pom.xml
├── .env.example
├── Dockerfile
├── docker-compose.yml
└── .github/workflows/ci.yml
```

---

## Spring Boot — Dockerfile

```dockerfile
# Build stage
FROM maven:3.9-eclipse-temurin-21-alpine AS builder
WORKDIR /app
COPY pom.xml .
RUN mvn dependency:go-offline -q
COPY src ./src
RUN mvn package -DskipTests -q

# Runtime stage
FROM eclipse-temurin:21-jre-alpine
WORKDIR /app
RUN addgroup -S spring && adduser -S spring -G spring
COPY --from=builder /app/target/*.jar app.jar
EXPOSE 8080
HEALTHCHECK --interval=30s --timeout=5s --start-period=30s --retries=3 \
  CMD wget -qO- http://localhost:8080/actuator/health/liveness || exit 1
USER spring
ENTRYPOINT ["java", "-jar", "app.jar"]
```

---

## Spring Boot — docker-compose.yml

```yaml
services:
  {{component-name}}:
    build: .
    ports:
      - "${PORT:-8080}:8080"
    environment:
      DATABASE_URL: jdbc:postgresql://db:5432/${DB_NAME:-{{component-name}}_dev}
      SPRING_DATASOURCE_USERNAME: ${DB_USER:-postgres}
      SPRING_DATASOURCE_PASSWORD: ${DB_PASSWORD:-postgres}
      AUTH_ISSUER_URI: ${AUTH_ISSUER_URI:-https://placeholder.auth.example.com}
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

## Spring Boot — .env.example

```bash
PORT=8080

# Postgres
DATABASE_URL=jdbc:postgresql://localhost:5432/{{component-name}}_dev
DB_NAME={{component-name}}_dev
DB_USER=postgres
DB_PASSWORD=postgres
DB_PORT=5432

# Auth — replace with actual issuer URI (Clerk, Auth0, Cognito, etc.)
AUTH_ISSUER_URI=https://your-auth-provider/

# SENTRY_DSN=      # TODO (growth): add error tracking

# STAGING DATABASE_URL=...
# PRODUCTION DATABASE_URL=...
```

---

## Spring Boot — CI Workflow

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
    services:
      postgres:
        image: postgres:16-alpine
        env:
          POSTGRES_DB: testdb
          POSTGRES_USER: postgres
          POSTGRES_PASSWORD: postgres
        ports:
          - 5432:5432
        options: >-
          --health-cmd pg_isready
          --health-interval 5s
          --health-timeout 5s
          --health-retries 5

    steps:
      - uses: actions/checkout@v4

      - uses: actions/setup-java@v4
        with:
          java-version: 21
          distribution: temurin
          cache: maven

      - name: Build and test
        run: mvn verify -q
        env:
          DATABASE_URL: jdbc:postgresql://localhost:5432/testdb
          SPRING_DATASOURCE_USERNAME: postgres
          SPRING_DATASOURCE_PASSWORD: postgres
          AUTH_ISSUER_URI: https://placeholder.auth.example.com

      - name: Check for vulnerabilities
        run: mvn dependency-check:check -q || true
```
