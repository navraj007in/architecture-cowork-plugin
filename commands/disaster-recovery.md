---
description: Design disaster recovery strategy with RTO/RPO targets, backup config, and incident runbooks
---

# /architect:disaster-recovery

## Trigger

`/architect:disaster-recovery [options]`

Options:
- `[non_interactive:true]` — derive targets from SDL, generate standard runbooks

## Purpose

Every system will fail. This command generates a disaster recovery (DR) strategy document with RTO (Recovery Time Objective) and RPO (Recovery Point Objective) targets tailored to your stage, backup configuration, cross-region failover patterns, and incident runbooks. Ensures business continuity and reduces mean-time-to-recovery (MTTR) under pressure.

## Workflow

## Quick Navigation

| Phase | Steps |
|-------|-------|
| **Setup** | [Step 1](#step-1-read-context) |
| **Generation** | [Step 2](#step-2-generate-strategy) · [Step 3](#step-3-generate-runbooks) |
| **Completion** | [Step 4](#step-4-log-activity) · [Step 5](#step-5-signal-completion) |

### Step 1: Read Context

ℹ️ **CONTEXT LOADING:** _state.json → SDL → tech stack

**Read**:
- `_state.json.project.stage` (MVP/growth/enterprise → RTO/RPO targets)
- `_state.json.tech_stack` (database, deployment platform)
- SDL `nonFunctional` section for availability targets
- Scaffolded infrastructure (docker-compose.yml, k8s configs)

### Step 2: Generate RTO/RPO Strategy

Create `docs/disaster-recovery/strategy.md`:

**By stage:**

| Stage | Availability SLO | RTO Target | RPO Target | Backup Freq | Multi-Region |
|-------|------------------|-----------|-----------|-------------|-------------|
| **MVP** | 99% | 4 hours | 24 hours | Weekly | No |
| **Growth** | 99.5% | 1 hour | 1 hour | Daily | Maybe (one standby) |
| **Enterprise** | 99.9% | 15 min | 15 min | Hourly | Yes (active-active) |

**Backup configuration**:
- Database: daily snapshots (AWS RDS, automated)
- Application state: stored in database (no separate state)
- Secrets: encrypted in AWS Secrets Manager
- Infrastructure-as-code: git repository (single source of truth)

**Failover patterns**:
- Single-region: RDS automated failover to replica
- Multi-region: DNS failover (Route 53 health checks)
- Active-active: load balancing across regions

### Step 3: Generate Incident Runbooks

Create `docs/disaster-recovery/runbooks/`:

**`database-failure.md`** — When the primary database is down

```markdown
## Objective

Restore database access within RTO target. Prevent data loss beyond RPO.

## Detection

- Alerts: Database connection pool exhausted
- Monitoring: No successful DB connections for 30 seconds
- Manual: Cannot connect via `psql $DATABASE_URL`

## Assessment (< 2 min)

1. Is the database server running?
   ```bash
   aws rds describe-db-instances --db-instance-identifier prod-db
   ```

2. Can replica take over?
   ```bash
   aws rds describe-db-instances --query 'DBInstances[?DBInstanceIdentifier==`prod-db-replica`]'
   ```

3. How much data loss acceptable? (check RPO target)

## Remediation (< RTO)

### If Primary is Down, Replica Available

```bash
# Promote replica (auto-promotion: ~2 min)
aws rds promote-read-replica --db-instance-identifier prod-db-replica

# Update connection string
# Update all apps to point to new primary
# Restart app services
```

### If Both Down

```bash
# Restore from last backup
aws rds restore-db-instance-from-db-snapshot \
  --db-instance-identifier prod-db-restored \
  --db-snapshot-identifier prod-db-snapshot-latest

# Update connection string
# Expected downtime: 15-30 minutes
```

## Post-Incident

- [ ] Document root cause
- [ ] Check backup integrity
- [ ] Verify replication lag (should be < RPO target)
- [ ] Schedule post-mortem (within 24h)
```

**`network-outage.md`** — Regional network partition

**`secrets-leak.md`** — Compromised API keys or credentials

**`data-corruption.md`** — Data in database is invalid/corrupted

**`volume-full.md`** — Disk space exhausted

### Step 4: Log Activity

```json
{"ts":"<ISO-8601>","phase":"disaster-recovery","outcome":"completed","stage":"growth","rto_minutes":60,"rpo_minutes":60,"runbooks":5,"files_generated":8,"summary":"DR strategy: Growth stage (RTO 1h, RPO 1h). Daily backups, single-region failover, 5 incident runbooks."}
```

### Step 5: Signal Completion

```
[DISASTER_RECOVERY_DONE]
```

## Error Handling

### Missing Tech Stack Info

If `tech_stack` incomplete:
- Report: "Tech stack not fully specified. Run `/architect:scaffold` first."
- Continue with generic strategy

### Unable to Write Docs

If `docs/disaster-recovery/` cannot be created:
- Stop, report error, do NOT emit completion marker

## Output Rules

- Use the **founder-communication** skill for tone
- RTO/RPO targets must match stage (MVP lenient, Enterprise strict)
- All runbooks must be copy-paste ready (shell commands included)
- Include estimated downtime and data loss per scenario
- Prioritize by likelihood (database > network > secrets >> volume-full)
- Do NOT include the CTA footer
