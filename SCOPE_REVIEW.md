# Architecture-Cowork Plugin Scope Review

**Date:** 2026-04-06  
**Status:** Current snapshot after audit remediation

## Repository Snapshot

| Area | Count | Notes |
|------|-------|-------|
| Canonical commands | 52 | Split files like `implement-*` and `review-*` map to one user-facing command each |
| Agent specs | 15 | Under `agents/` |
| Skills | 31 | Under `skills/` |
| SDL starter templates | 14 | Under `templates/` |

## Coverage Summary

The plugin covers the full architecture lifecycle across ideation, SDL generation, design, prototyping, scaffolding, implementation, review, testing, operations, stakeholder communication, and planning.

### Major Capability Areas

- Discovery and validation: `problem-validation`, `quick-spec`, `deep-research`, `user-personas`
- Architecture design: `blueprint`, `sdl`, `compare-stack`, `complexity-check`, `agent-spec`
- Design and prototyping: `design-system`, `wireframes`, `prototype`, `prototype-iterate`
- Code generation: `scaffold`, `scaffold-component`, `generate-data-model`, `implement`
- Quality and assurance: `review`, `security-scan`, `well-architected`, `generate-tests`, `compliance`, `accessibility-audit`, `load-test`
- Operations and delivery: `setup-env`, `check-env`, `setup-cicd`, `setup-monitoring`, `publish-api-docs`, `export-diagrams`, `launch-check`, `launch-checklist`
- Planning and roadmap: `mvp-scope`, `risk-register`, `technical-roadmap`, `user-journeys`, `sprint-status`, `sync-backlog`
- Stakeholder outputs: `pitch-deck`, `investor-update`, `hiring-brief`, `onboarding-pack`, `cost-estimate`

## Current Reliability Notes

- SDL documentation and examples are aligned on v1.1.
- Review artifacts are routed to `.archon/reviews/`.
- README command inventory matches the shipped command surface.
- Marketplace and plugin metadata are version-aligned at `1.1.0`.
- Legacy skill docs that referenced nonexistent slash commands have been redirected to existing commands or rewritten as non-command workflows.

## Maintenance Rules

- Update this file whenever commands are added, removed, or renamed.
- Recompute the command count from the repo, not from historical notes.
- Treat this file as a point-in-time summary, not a roadmap or changelog.
