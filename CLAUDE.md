# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

**Spec Bot (規格機器人)**: A Specification-Driven Development (SDD) toolkit that transforms natural language feature descriptions into structured, executable specifications. The system guides features through a rigorous workflow: `specify → clarify → plan → tasks → implement → analyze`.

**Core Purpose**: Automate the conversion of Business Requirements Documents (BRD) into System Design Documents (SDD) through AI-assisted workflows, ensuring consistency, traceability, and constitutional compliance across all project artifacts.

**Target Extension** (draft/extension.md): Expanding to support banking enterprise workflows with additional templates for process documentation, security requirements, compliance, and audit trails (00_meta.md through 70_nfr.md structure).

## Architecture

### Workflow Pipeline

The SDD workflow follows a strict sequential process enforced by slash commands:

1. **`/speckit.specify <description>`** - Generate spec.md from natural language
   - Creates feature branch (`###-feature-name` format)
   - Generates user stories with Gherkin scenarios (Given-When-Then)
   - Produces functional requirements and success criteria
   - Validates against spec quality checklist

2. **`/speckit.clarify`** - Resolve ambiguities (max 5 questions per session)
   - Detects underspecified requirements across 10+ taxonomy categories
   - Interactive Q&A with recommended defaults
   - Incrementally updates spec.md with clarifications
   - Creates `## Clarifications` section tracking session history

3. **`/speckit.plan`** - Generate implementation design artifacts
   - **Phase 0**: Research unknowns → research.md
   - **Phase 1**: Generate data-model.md, contracts/, quickstart.md
   - Updates agent-specific context files
   - Validates against constitutional checks

4. **`/speckit.tasks`** - Generate executable task breakdown
   - Organizes tasks by user story priority (P1, P2, P3)
   - Follows strict checklist format: `- [ ] T### [P?] [Story] Description with file path`
   - Identifies parallel execution opportunities ([P] flag)
   - Maps requirements to implementation tasks

5. **`/speckit.implement`** - Execute implementation with TDD
   - Validates all checklists before starting
   - Follows dependency order: Setup → Foundational → User Stories → Polish
   - Manages .gitignore and Docker ignore patterns
   - Marks tasks completed in tasks.md

6. **`/speckit.analyze`** - Cross-artifact consistency validation
   - **Read-only analysis** - does not modify files
   - Detects: duplication, ambiguity, underspecification, coverage gaps, conflicts
   - Validates constitutional compliance (CRITICAL severity for violations)
   - Generates structured markdown report with severity scoring

7. **`/speckit.checklist`** - Generate domain-specific quality checklists
   - "Unit tests for requirements" - validates requirement quality, not implementation
   - Categories: completeness, clarity, consistency, acceptance criteria, coverage
   - Stored in `checklists/` directory (ux.md, api.md, security.md, etc.)

8. **`/speckit.constitution`** - Manage project governance principles
   - Defines non-negotiable architectural constraints
   - Enforced via "Constitution Check" gates in plan.md
   - Requires explicit justification for violations in "Complexity Tracking" section

### Directory Structure

```
.
├── .claude/
│   └── commands/          # Slash command definitions (speckit.*.md)
├── .specify/
│   ├── memory/
│   │   └── constitution.md    # Project governance rules (v2.0.0)
│   ├── scripts/bash/          # Shell utilities for workflow automation
│   │   ├── create-new-feature.sh
│   │   ├── check-prerequisites.sh
│   │   ├── setup-plan.sh
│   │   └── update-agent-context.sh
│   └── templates/             # Markdown templates for all artifacts
│       ├── spec-template.md   # User stories + acceptance criteria
│       ├── plan-template.md   # Technical context + architecture
│       ├── tasks-template.md  # Phase-based task breakdown
│       ├── checklist-template.md
│       └── agent-file-template.md
├── specs/
│   └── ###-feature-name/      # Feature-specific artifacts (auto-created)
│       ├── spec.md            # Feature specification
│       ├── plan.md            # Implementation plan
│       ├── tasks.md           # Executable task list
│       ├── research.md        # Phase 0 research decisions
│       ├── data-model.md      # Entity definitions + relationships
│       ├── quickstart.md      # Getting started guide
│       ├── contracts/         # API specifications (OpenAPI/GraphQL)
│       └── checklists/        # Quality validation checklists
└── draft/
    └── extension.md           # Banking enterprise template proposal
```

### Key Scripts (Workflow Utilities)

All scripts in `.specify/scripts/bash/` use `--json` mode for structured output:

- **create-new-feature.sh**: Branch creation with auto-numbering and conflict detection
  - Fetches remote branches and specs directory to determine next available number
  - Generates semantic branch names with stop-word filtering
  - Creates feature directory and initializes spec.md from template

- **check-prerequisites.sh**: Validates workflow state and returns artifact paths
  - Flags: `--json`, `--require-tasks`, `--include-tasks`, `--paths-only`
  - Returns: FEATURE_DIR, SPEC_FILE, IMPL_PLAN, TASKS, AVAILABLE_DOCS

- **setup-plan.sh**: Initializes planning phase with template copy

- **update-agent-context.sh**: Synchronizes agent-specific context files

### Constitutional Principles (v2.0.0)

The `.specify/memory/constitution.md` defines **10 core principles** that are enforced as gates:

**Critical Architectural Constraints:**
- **I. Single Source of Truth**: All state in GitHub (bot is stateless)
- **II. Lightweight Sandboxing**: All operations in ephemeral Docker containers
- **III. Test-Driven Development**: TDD with Gherkin scenarios (NON-NEGOTIABLE)
- **VIII. Zero Trust & Least Privilege**: Minimal scopes for GitHub/Slack/OpenAI APIs
- **IX. Grounded AI & Prompt Injection Defense**: RAG-based responses with source citations

**Quality & Simplicity:**
- **V. YAGNI (You Aren't Gonna Need It)**: Reject complexity not in spec.md
- **VII. Semantic Versioning**: MAJOR.MINOR.PATCH with migration guides

**Observability:**
- **VI. Full Traceability**: Structured JSON logs with correlation IDs

**Integration:**
- **X. Native Integration First**: Use official SDKs (Slack Bolt, PyGithub, OpenAI)

### Template Variables & Placeholders

All templates use consistent placeholder syntax:
- `[FEATURE NAME]`, `[###-feature-name]`, `[DATE]`
- `$ARGUMENTS` - User input passed to slash commands
- `[NEEDS CLARIFICATION]` - Marks unknowns (max 3 per spec)
- Priority markers: `P1`, `P2`, `P3` for user stories
- Task format: `T###`, `[P]` for parallel, `[US#]` for story mapping

## Common Development Patterns

### Creating a New Feature Specification

```bash
# 1. Generate spec from description (creates branch + spec.md)
/speckit.specify <feature description>

# 2. Clarify ambiguities (optional but recommended)
/speckit.clarify

# 3. Generate implementation plan (research + design)
/speckit.plan

# 4. Generate task breakdown
/speckit.tasks

# 5. Validate consistency (before implementation)
/speckit.analyze

# 6. Execute implementation
/speckit.implement
```

### Understanding Artifact Relationships

- **spec.md** defines WHAT (requirements, user stories, success criteria)
- **plan.md** defines HOW (architecture, tech stack, structure)
- **tasks.md** defines WHEN (phases, dependencies, execution order)
- **checklists/** validate WHY (requirement quality gates)
- **constitution.md** enforces CONSTRAINTS (non-negotiable principles)

### Task Organization Rules

Tasks in tasks.md follow strict structure:

```markdown
## Phase 1: Setup (Shared Infrastructure)
- [ ] T001 Create project structure per implementation plan
- [ ] T002 [P] Configure linting and formatting tools

## Phase 2: Foundational (Blocking Prerequisites)
- [ ] T004 Setup database schema and migration framework
- [ ] T005 [P] Implement authentication/authorization framework

## Phase 3: User Story 1 - [Title] (Priority: P1) 🎯 MVP
- [ ] T010 [P] [US1] Contract tests for [endpoint] in tests/contract/
- [ ] T012 [P] [US1] Create [Entity1] model in src/models/entity1.py
- [ ] T014 [US1] Implement [Service] in src/services/service.py
```

**Key Conventions:**
- `[P]` = Can run in parallel (different files, no dependencies)
- `[US#]` = Maps to specific User Story from spec.md
- File paths must be explicit in every task description
- Phases must complete sequentially; tasks within phases can parallelize

### Constitutional Compliance

When violating constitutional principles:

1. Document in plan.md "Complexity Tracking" section:
   ```markdown
   | Violation | Why Needed | Why Simpler Alternative Rejected |
   |-----------|------------|----------------------------------|
   | 4th package | Current need | Why 3 packages insufficient |
   ```

2. Obtain stakeholder approval before proceeding
3. Update CHANGELOG.md if introducing breaking changes

### Git Workflow

- Feature branches: `###-feature-name` (auto-numbered)
- Bot branches: `bot/spec-{timestamp}` or `bot/{feature-name}`
- Commit messages: Conventional Commits format (`feat:`, `fix:`, `docs:`, `refactor:`)
- All SDD artifacts committed to feature branch, merged via PR with review

## Important Notes

### Language Requirements
- **All project artifacts must use Traditional Chinese (繁體中文)**: spec.md, plan.md, tasks.md, commit messages, PR descriptions, code comments
- **Exceptions**: Code variables/functions (English per PEP 8), external API docs, technical terms (e.g., "Docker container", "REST API")

### Shell Script Invocation
- All bash scripts support `--json` flag for structured output
- JSON parsing required for robust workflow automation
- Single-quote escaping example: `'I'"'"'m Groot'` or use double quotes

### Checklist Philosophy
Checklists are "unit tests for requirements" - they validate **requirement quality**, not implementation:
- ✅ "Are error handling requirements defined for all API failure modes?"
- ✅ "Is 'fast loading' quantified with specific timing thresholds?"
- ❌ NOT "Does the button click work correctly?" (that's an implementation test)

### Read-Only Analysis
The `/speckit.analyze` command is **strictly read-only**. It identifies issues but never auto-fixes. Remediation requires explicit user approval.

## Bank Profile Extension (Enterprise SDD Workflow)

The system now supports **banking/enterprise workflows** with additional pre-specification templates:

### Directory Structure

**Bank Profile** documents are stored at **project level** (not feature level):

```
.
├── bank-profile/           # Project-level Bank SDD Profile
│   ├── 00_meta.md          # Project metadata, stakeholders, priority
│   ├── 10_business.md      # Business goals, KPIs, user stories
│   ├── 20_process.md       # As-Is / To-Be flows, exception scenarios
│   ├── 30_risk_control.md  # Risks, control measures, RACI matrix
│   ├── 40_infosec.md       # Security requirements, permission matrix
│   ├── 50_compliance.md    # Regulatory compliance (GDPR, PDPA, etc.)
│   ├── 60_audit.md         # Auditability requirements (logs, retention)
│   └── 70_nfr.md           # Non-functional requirements (SLA, RTO/RPO)
├── specs/
│   └── ###-feature-name/   # Feature-specific SDD (generated from Bank Profile)
│       ├── spec.md         # Technical specification
│       ├── plan.md         # System design
│       └── tasks.md        # Task breakdown
```

### Bank Profile Workflow

**Complete enterprise workflow** (Bank Profile → Project Summary → Constitution → Feature SDD):

```bash
# Phase 1: Project Context (00-20) - Business Requirements
/speckit.meta              # → bank-profile/00_meta.md
/speckit.business          # → bank-profile/10_business.md
/speckit.process           # → bank-profile/20_process.md

# Phase 2: Risk & Security (30-40) - Control Requirements
/speckit.risk              # → bank-profile/30_risk_control.md
/speckit.infosec           # → bank-profile/40_infosec.md

# Phase 3: Compliance & Audit (50-60) - Regulatory Requirements
/speckit.compliance        # → bank-profile/50_compliance.md
/speckit.audit             # → bank-profile/60_audit.md

# Phase 4: Non-Functional Requirements (70)
/speckit.nfr               # → bank-profile/70_nfr.md

# Phase 5: Review & Constitution (審核與憲法建立) - 關鍵整合步驟
/speckit.review            # 審核 00-70 完整性與一致性
                          # → 生成 PROJECT_SUMMARY.md (專案總結)
                          # → 提煉專案特定約束

/speckit.constitution      # 建立專案憲法
                          # → 讀取 PROJECT_SUMMARY.md
                          # → 更新 .specify/memory/constitution.md
                          # → 整合通用原則 + 專案特定約束

# Phase 6: Feature Development Cycle (功能開發循環,可重複)
/speckit.specify <功能描述>  # → specs/###-feature-name/spec.md
                            # (自動整合 constitution 約束)
/speckit.clarify
/speckit.plan
/speckit.tasks
/speckit.analyze            # 驗證符合 constitution
/speckit.implement
```

### Key Characteristics

- **Project-Level**: Bank Profile (00-70) describes the entire project, not individual features
- **Feature-Level**: Technical SDD (spec/plan/tasks) implements specific features based on Bank Profile requirements
- **Review as Gate**: `/speckit.review` acts as quality gate, ensuring Bank Profile is complete and consistent before constitution building
- **Constitution as Foundation**: Project-specific constraints from constitution.md automatically apply to all features
- **Dependency-Aware**: Later commands (e.g., compliance) can reference earlier documents (e.g., risk, infosec)
- **Optional**: If Bank Profile files don't exist, commands generate from scratch with intelligent Q&A

### Critical Integration Points

1. **Bank Profile → Review**: `/speckit.review` validates 00-70 files and generates PROJECT_SUMMARY.md
2. **Review → Constitution**: `/speckit.constitution` reads PROJECT_SUMMARY.md to extract project-specific constraints
3. **Constitution → Features**: `/speckit.specify` automatically inherits constraints from constitution.md
4. **Features → Validation**: `/speckit.analyze` verifies spec.md complies with constitution

### Integration with Core SDD Workflow

- Bank Profile commands are **optional** - existing `specify → clarify → plan → tasks → implement` workflow still works
- Use Bank Profile when:
  - Working on banking/financial/healthcare projects with strict compliance
  - Need cross-department alignment (Business, InfoSec, Legal, Audit)
  - Regulatory requirements must be traceable to technical implementation
  - Project has non-negotiable constraints (tech stack, process, compliance)
- Skip Bank Profile for:
  - Simple internal tools
  - Rapid prototyping
  - Non-regulated industries
  - Projects without strict constraints

## Project Context

**Current Status**: Foundation phase - core SDD workflow templates and commands are defined. No implementation code exists yet (Python/Docker/bot integration pending).

**Primary Use Case**: Slack/GitHub/GPT-integrated bot for automating BRD → SDD transformation in enterprise environments.

**Version**: Constitution v2.0.0 (ratified 2025-11-13), migrated from generic MVP framework to Spec Bot specialization.
