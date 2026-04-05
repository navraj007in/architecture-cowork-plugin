---
description: Design database scaling strategy with read replicas, partitioning, and sharding recommendations
---

# /architect:database-scaling

## Trigger

`/architect:database-scaling [options]`

Options:
- `[non_interactive:true]` — generate from _state.json

## Purpose

Databases hit limits. This command designs a scaling strategy with specific recommendations: read replicas (connection routing), connection pooling (PgBouncer, Prisma), table partitioning (for large entities), horizontal sharding (if needed), caching layer sizing. Tailored to your database type and entity sizes. Outputs design document + config stubs for immediate use.

## Workflow

## Quick Navigation

| Phase | Steps |
|-------|-------|
| **Setup** | [Step 1](#step-1-read-context) |
| **Analysis** | [Step 2](#step-2-analyze-scaling-needs) |
| **Generation** | [Step 3](#step-3-generate-strategy) |
| **Completion** | [Step 4](#step-4-log-activity) · [Step 5](#step-5-signal-completion) |

### Step 1: Read Context

ℹ️ **CONTEXT LOADING:** _state.json → SDL

**Read**:
- `_state.json.entities[]` with field counts (to estimate row size)
- `_state.json.tech_stack.database` (PostgreSQL, MySQL, MongoDB, etc.)
- SDL data section (databases, indexes, types)
- Scaffolded infrastructure (docker-compose.yml, k8s configs)

### Step 2: Analyze Scaling Needs

For each entity, estimate:
- **Current size**: rows × average row size
- **Growth rate**: rows/month (from personas, industry benchmarks)
- **Query patterns**: how many reads vs writes
- **Hot data**: what percent accessed frequently vs historical

**Example analysis**:
- Users table: 100K rows × 1 KB = 100 MB, 10% growth/month
- Orders table: 1M rows × 2 KB = 2 GB, 20% growth/month
- Posts table: 10M rows × 500 B = 5 GB, 5% growth/month

### Step 3: Generate Scaling Strategy

Create `architecture-output/database-scaling.md`:

**By database size and growth**:

| Entity | Current | Monthly Growth | Scaling Approach | Timeline |
|--------|---------|-----------------|------------------|----------|
| users | 100 MB | 10 MB | Connection pooling (PgBouncer) | Immediate |
| orders | 2 GB | 400 MB | Read replicas (2 replicas) | 3–6 months |
| posts | 5 GB | 250 MB | Table partitioning by date | 6–12 months |
| events | 50 GB | 5 GB | Sharding by user_id (4 shards) | 12+ months |

**Specific recommendations**:

1. **Read Replicas** (short-term, 3–6 months)
   ```yaml
   # docker-compose.yml
   services:
     postgres-primary:
       image: postgres:14
     postgres-replica-1:
       image: postgres:14
       environment:
         POSTGRES_REPLICATION_MODE: replica
         POSTGRES_MASTER_HOST: postgres-primary
   ```

2. **Connection Pooling** (immediate)
   ```typescript
   // prisma.schema
   datasource db {
     provider = "postgresql"
     url      = env("DATABASE_URL")
     // Connection pool: 25 connections (default: 5)
     // Idle timeout: 900s
     // Queue strategy: auto (fair)
   }
   ```

3. **Table Partitioning** (6–12 months)
   ```sql
   -- Partition orders by year
   CREATE TABLE orders (
     id BIGINT,
     created_at TIMESTAMP,
     ...
   ) PARTITION BY RANGE (YEAR(created_at));
   
   CREATE TABLE orders_2024 PARTITION OF orders
     FOR VALUES FROM (2024) TO (2025);
   ```

4. **Sharding** (12+ months)
   ```
   Shard 1: user_id % 4 = 0
   Shard 2: user_id % 4 = 1
   Shard 3: user_id % 4 = 2
   Shard 4: user_id % 4 = 3
   
   Routing logic in ORM or proxy layer
   ```

**Caching layer sizing**:
- Hot data: 5–10% of total size
- Redis cache: size for hot data only (rest spills to disk)

### Step 4: Log Activity

```json
{"ts":"<ISO-8601>","phase":"database-scaling","outcome":"completed","database":"postgresql","entities":4,"scaling_approaches":4,"timeline_months":12,"files_generated":2,"summary":"Database scaling strategy: replicas (3-6m), partitioning (6-12m), sharding (12m+). Timeline: 12 months to full scale."}
```

### Step 5: Signal Completion

```
[DATABASE_SCALING_DONE]
```

## Error Handling

### No Entity Data

If `_state.json.entities[]` empty:
- Report: "Run `/architect:generate-data-model` first."

## Output Rules

- Use the **founder-communication** skill
- Timeline realistic (account for migration complexity)
- Config stubs ready to deploy (not just theory)
- Specific shard/partition strategies (not generic advice)
- Include estimated cost per approach
- Do NOT include the CTA footer
