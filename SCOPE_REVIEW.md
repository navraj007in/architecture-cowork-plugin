# Architecture-Cowork Plugin Scope Review

**Date:** 2026-04-24  
**Status:** Current snapshot — Phase 0 (audit fixes) complete

## Repository Snapshot

| Area | Count | Notes |
|------|-------|-------|
| Canonical commands | 52 | User-facing commands (65 files including split implementations like `implement-1/2`, `review-1/2`, index files) |
| Agent specs | 18 | Under `agents/` — delegated execution for complex, multi-step tasks |
| Skills/capabilities | 85 | Under `skills/` — reusable instruction modules (29 high-level skills, 85 total files) |
| SDL starter templates | 15 | Under `templates/` — domain-specific baseline specifications |

## Coverage Summary

The plugin covers the full architecture lifecycle from ideation through production, spanning discovery, design, code generation, quality assurance, operations, and stakeholder communication.

### Major Capability Areas

**Ideation & Validation** (4 commands)
- `problem-validation`, `quick-spec`, `deep-research`, `user-personas`

**Architecture & Design** (9 commands)
- `blueprint`, `sdl`, `sdl-drift`, `compare-stack`, `complexity-check`, `agent-spec`, `design-system`, `wireframes`, `visualise`

**Prototyping & Code Generation** (5 commands)
- `prototype`, `prototype-iterate`, `scaffold`, `scaffold-component`, `implement`

**Quality, Testing & Security** (8 commands)
- `generate-tests`, `generate-data-model`, `review`, `security-scan`, `well-architected`, `compliance`, `accessibility-audit`, `load-test`

**Operations & Infrastructure** (9 commands)
- `setup-env`, `check-env`, `setup-cicd`, `setup-monitoring`, `publish-api-docs`, `export-diagrams`, `launch-check`, `launch-checklist`, `production-readiness`

**Planning, Roadmap & Stakeholder** (10 commands)
- `mvp-scope`, `risk-register`, `technical-roadmap`, `user-journeys`, `sprint-status`, `sync-backlog`, `pitch-deck`, `investor-update`, `hiring-brief`, `onboarding-pack`

**Infrastructure & Growth** (9 commands)
- `cost-estimate`, `database-scaling`, `disaster-recovery`, `seo`, `analytics-setup`, `i18n-setup`, `refactor-stack`, `import`, `grant-assistant` (future)

## Audit Status (Phase 0 Complete)

✅ **Resolved Issues (Phase 0 Complete):**
- [x] Scaffold output contract unified — production-starter code, no stubs, MVP-scope
- [x] Review output paths standardized to `architecture-output/review-pr-<N>.md`
- [x] README command inventory complete (52 canonical commands with descriptions)
- [x] Marketplace and plugin metadata versions synced (v2.0.0)
- [x] State validation script created + pre-commit hook installed
- [x] SDL versioning unified on v1.1 across all references (templates, examples, CLAUDE.md, README)
- [x] No references to nonexistent commands (grant-assistant marked as future)

## Quality Assurance

**Documentation:**
- ✅ CLAUDE.md — 524 lines of global execution rules (authoritative)
- ✅ README.md — 471 lines with all 54 commands documented
- ✅ AGENTS.md — 485 lines with agent specifications
- ✅ 17 reference modules covering schemas, patterns, design systems, pricing, compliance

**Automation:**
- ✅ `scripts/validate-state.sh` — validates `_state.json` schema compliance
- ✅ `.git/hooks/pre-commit` — auto-validates state files before commits

**Consistency:**
- ✅ All commands follow request-routing rules (in CLAUDE.md §40-57)
- ✅ All output files follow split-threshold rules (~15KB per file)
- ✅ All agents documented with input/output contracts
- ✅ Activity logging standardized (ISO-8601 timestamps, JSON format)

## Known Limitations

1. No automated testing of generated code scaffolds (recommended for Phase 1)
2. No multi-option architecture generator yet (recommended for Phase 3)
3. No continuous drift detection (recommended for Phase 4)
4. No team approval workflows (recommended for Phase 4)

See `ROADMAP_COMPREHENSIVE.md` for enhancement roadmap.

## Maintenance Rules

- Update this file when commands are added, removed, or renamed
- Recompute counts from repo, not historical notes (use bash commands above)
- Treat as point-in-time snapshot, not a roadmap
- Link to remediation issues in AUDIT_FINDINGS.md if unresolved
