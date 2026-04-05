# Architecture Cowork Plugin Audit Findings

Date: 2026-04-06

## Scope

This audit covers the current repository contents in `/Users/nexper/Code/architecture/backend/architecture-cowork-plugin`.

The repository is primarily a specification-driven plugin: commands, skills, agents, templates, and plugin metadata. The findings below focus on correctness, internal consistency, artifact paths, command surface accuracy, and documentation reliability.

## Findings

### 1. SDL versioning is internally inconsistent

Severity: High

The repository defines two incompatible SDL versions at the same time.

- [`commands/import.md:113`](/Users/nexper/Code/architecture/backend/architecture-cowork-plugin/commands/import.md:113) requires a `v1.1-compliant` SDL.
- [`commands/import.md:210`](/Users/nexper/Code/architecture/backend/architecture-cowork-plugin/commands/import.md:210) hard-codes `sdlVersion: "1.1"`.
- [`commands/sdl.md:72`](/Users/nexper/Code/architecture/backend/architecture-cowork-plugin/commands/sdl.md:72) still shows `sdlVersion: "0.1"`.
- [`references/sdl-schema.md:1`](/Users/nexper/Code/architecture/backend/architecture-cowork-plugin/references/sdl-schema.md:1) documents SDL v0.1 and says `sdlVersion` is always `"0.1"`.
- [`README.md:193`](/Users/nexper/Code/architecture/backend/architecture-cowork-plugin/README.md:193) uses `sdlVersion: "0.1"` in the public example.
- The shipped templates under [`templates/`](/Users/nexper/Code/architecture/backend/architecture-cowork-plugin/templates) also still use `sdlVersion: "0.1"`.

Impact:

- Different commands can generate incompatible SDL artifacts.
- Downstream commands may read a schema version they were not written against.
- Users cannot tell which SDL version is authoritative.

### 2. Scaffold promises conflict with actual scaffolder behavior

Severity: High

The scaffold contract says generated code must not contain stubs or TODOs, but the scaffolder instructions explicitly require them.

- [`commands/scaffold-component.md:91`](/Users/nexper/Code/architecture/backend/architecture-cowork-plugin/commands/scaffold-component.md:91) says generated files must contain real working logic, not TODOs or placeholder comments.
- [`commands/scaffold-component.md:220`](/Users/nexper/Code/architecture/backend/architecture-cowork-plugin/commands/scaffold-component.md:220) forbids empty pages and placeholders.
- [`commands/scaffold-component.md:432`](/Users/nexper/Code/architecture/backend/architecture-cowork-plugin/commands/scaffold-component.md:432) repeats that all files must contain real code with no placeholder comments or empty bodies.
- [`agents/scaffolder.md:231`](/Users/nexper/Code/architecture/backend/architecture-cowork-plugin/agents/scaffolder.md:231) instructs the agent to create model/entity placeholder files.
- [`agents/scaffolder.md:246`](/Users/nexper/Code/architecture/backend/architecture-cowork-plugin/agents/scaffolder.md:246) requires minimal skeletons with TODO comments.
- [`agents/scaffolder.md:254`](/Users/nexper/Code/architecture/backend/architecture-cowork-plugin/agents/scaffolder.md:254) requires rate limiting TODO stubs at MVP depth.
- [`agents/scaffolder.md:270`](/Users/nexper/Code/architecture/backend/architecture-cowork-plugin/agents/scaffolder.md:270) says auth stubs should remain placeholders at MVP.

Impact:

- The command cannot satisfy its documented output contract.
- Generated projects will vary based on which file the agent follows.
- Users are likely to see “production-starter” claims while receiving partial stubbed code.

### 3. Review output paths are inconsistent

Severity: High

The global rules and the review command disagree on where review artifacts are written.

- [`AGENTS.md:234`](/Users/nexper/Code/architecture/backend/architecture-cowork-plugin/AGENTS.md:234) says `review` writes `architecture-output/review-pr-<N>.md` in `--pr` mode.
- [`commands/review-index.md:55`](/Users/nexper/Code/architecture/backend/architecture-cowork-plugin/commands/review-index.md:55) says review reports are written to `.archon/reviews/`.
- [`commands/review-index.md:64`](/Users/nexper/Code/architecture/backend/architecture-cowork-plugin/commands/review-index.md:64) explicitly says never to write review output to `architecture-output/`.

Impact:

- Tooling and users cannot reliably locate review artifacts.
- Any workflow that expects one output path will miss reports generated under the other policy.

### 4. The repo advertises `/architect:` commands that do not exist

Severity: High

Several skills document command entry points that are not implemented in `commands/`.

Examples:

- [`skills/validate/SKILL.md:437`](/Users/nexper/Code/architecture/backend/architecture-cowork-plugin/skills/validate/SKILL.md:437) advertises `/architect:validate`.
- [`skills/export-docx/SKILL.md:356`](/Users/nexper/Code/architecture/backend/architecture-cowork-plugin/skills/export-docx/SKILL.md:356) advertises `/architect:export-docx`.
- [`skills/export-openapi/SKILL.md:814`](/Users/nexper/Code/architecture/backend/architecture-cowork-plugin/skills/export-openapi/SKILL.md:814) advertises `/architect:export-openapi`.
- [`skills/security-audit/SKILL.md:617`](/Users/nexper/Code/architecture/backend/architecture-cowork-plugin/skills/security-audit/SKILL.md:617) advertises `/architect:security-audit`.
- [`skills/export-diagrams/SKILL.md:21`](/Users/nexper/Code/architecture/backend/architecture-cowork-plugin/skills/export-diagrams/SKILL.md:21) refers users to `/architect:stakeholder-doc` and `/architect:export-docx`.

Impact:

- Users are taught to invoke commands that the plugin cannot route.
- Other command and skill docs depend on nonexistent flows.
- This breaks user trust in the documented command surface.

### 5. `SCOPE_REVIEW.md` is internally contradictory and unreliable

Severity: Medium

The audit summary file contains multiple contradictions and stale counts.

- [`SCOPE_REVIEW.md:8`](/Users/nexper/Code/architecture/backend/architecture-cowork-plugin/SCOPE_REVIEW.md:8) says all 15 critical gaps are resolved.
- [`SCOPE_REVIEW.md:83`](/Users/nexper/Code/architecture/backend/architecture-cowork-plugin/SCOPE_REVIEW.md:83) still says there is no dedicated monitoring setup and no test generation command.
- [`SCOPE_REVIEW.md:91`](/Users/nexper/Code/architecture/backend/architecture-cowork-plugin/SCOPE_REVIEW.md:91) later says test generation and monitoring setup do exist.
- [`SCOPE_REVIEW.md:145`](/Users/nexper/Code/architecture/backend/architecture-cowork-plugin/SCOPE_REVIEW.md:145) still lists compliance, disaster recovery, and load testing as enterprise gaps, despite earlier claiming those gaps were resolved.
- [`SCOPE_REVIEW.md:6`](/Users/nexper/Code/architecture/backend/architecture-cowork-plugin/SCOPE_REVIEW.md:6) refers to 50 commands.
- [`SCOPE_REVIEW.md:68`](/Users/nexper/Code/architecture/backend/architecture-cowork-plugin/SCOPE_REVIEW.md:68) reports a total of 44 commands.
- The current repo contains 52 canonical commands after normalizing split command files like `implement-*` and `review-*`.

Impact:

- The file cannot be used as a trustworthy health or scope summary.
- Product and roadmap decisions based on it may be wrong.

### 6. Marketplace metadata versions are out of sync

Severity: Medium

Plugin metadata declares different versions in different files.

- [` .claude-plugin/plugin.json:4`](/Users/nexper/Code/architecture/backend/architecture-cowork-plugin/.claude-plugin/plugin.json:4) declares version `1.1.0`.
- [` .claude-plugin/marketplace.json:15`](/Users/nexper/Code/architecture/backend/architecture-cowork-plugin/.claude-plugin/marketplace.json:15) declares version `1.0.0`.

Impact:

- Marketplace consumers may install or display stale version information.
- Release tracking becomes ambiguous.

### 7. The README command inventory is incomplete

Severity: Medium

The README exposes fewer commands than the repository actually ships.

- [`README.md:30`](/Users/nexper/Code/architecture/backend/architecture-cowork-plugin/README.md:30) lists 38 commands.
- The repo currently exposes 52 canonical commands.
- Missing from the README list are commands such as:
  - `check-env`
  - `launch-check`
  - `mvp-scope`
  - `pitch-deck`
  - `problem-validation`
  - `prototype`
  - `prototype-iterate`
  - `risk-register`
  - `sprint-status`
  - `technical-roadmap`
  - `user-journeys`
  - `user-personas`
  - `visualise`
  - `wireframes`

Impact:

- Users cannot discover a large part of the plugin from the main documentation.
- The public description understates the shipped feature surface.

## Additional Notes

- The repository contains no application source code beyond plugin metadata and markdown instructions, so this audit focused on spec correctness, routing accuracy, artifact conventions, and documentation integrity.
- There are also several missing relative links in agent and skill documents, but they were treated as secondary compared with the command-surface and contract inconsistencies above.

## Recommended Remediation Order

1. Unify SDL versioning across commands, schema references, templates, and README.
2. Resolve scaffold contract conflicts by choosing either “fully working output” or “starter/stub output” and updating all related docs and agents accordingly.
3. Standardize review artifact paths in both global rules and command docs.
4. Remove or implement nonexistent commands referenced from skills.
5. Rewrite `SCOPE_REVIEW.md` from current repo state.
6. Sync plugin version metadata.
7. Update README command inventory to match the actual command set.
