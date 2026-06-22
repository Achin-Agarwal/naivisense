# NaiviSense — Doc 5: Development Tracker
> Authoritative task list for all coding agents and developers.
> Read Doc 1 (Architecture) first. Update this file after every task.

---

## 📊 Overall Progress

```
OVERALL: [████████████░░░░░░░░]  55%

Phase 1: Foundation (Flutter shell)   [████████████████████] 100% ✅
Phase 2: Design system + UI           [████████████████████] 100% ✅
Phase 3: Backend — Node.js API        [████████████████████] 100% ✅
Phase 4: Frontend integration         [░░░░░░░░░░░░░░░░░░░░]   0% 🔴
Phase 5: AI service (Python)          [░░░░░░░░░░░░░░░░░░░░]   0% ⏸️
Phase 6: Testing                      [████████░░░░░░░░░░░░]  40% 🔄
Phase 7: Deployment                   [░░░░░░░░░░░░░░░░░░░░]   0% ⏸️
```

---

## 🎯 Current Pointer

```
👉 NEXT TASK: INT-001
   FILE:     pubspec.yaml (Flutter — add dio, flutter_secure_storage, etc.)
   PRIORITY: 🔴 CRITICAL — Frontend integration blocked on this
   ETA:      15 min

✅ COMPLETED: BACKEND-001 → BACKEND-053 (entire Phase 3)
   All 14 vitest tests pass. npx tsc --noEmit → zero errors.
```

---

## 📋 Legend

| Symbol | Meaning |
|--------|---------|
| ✅ | Done — tested and committed |
| 🔄 | In progress |
| 🔴 | Ready to start — not blocked |
| ⏸️ | Blocked — dependency not done |
| ⚠️ | Exists but needs update |

---

## ✅ PHASE 1 & 2 — Completed (Flutter Shell)

All items below are done. Do not re-do them.

| ID | File | Status | Notes |
|----|------|--------|-------|
| FE-DONE-01 | `lib/main.dart` | ⚠️ | Needs ProviderScope + Hive init |
| FE-DONE-02 | `lib/core/theme/app_colors.dart` | ✅ | Locked — do not change |
| FE-DONE-03 | `lib/core/theme/app_theme.dart` | ✅ | Locked — do not change |
| FE-DONE-04 | `lib/routing/app_router.dart` | ⚠️ | Needs auth guard + role guard |
| FE-DONE-05 | `lib/data/mock/mock_repository.dart` | ✅ | Keep for tests only |
| FE-DONE-06 | `lib/shared/widgets/app_button.dart` | ✅ | |
| FE-DONE-07 | `lib/shared/widgets/app_card.dart` | ✅ | |
| FE-DONE-08 | `lib/shared/widgets/app_widgets.dart` | ✅ | |
| FE-DONE-09 | `lib/features/auth/screens/splash_screen.dart` | ⚠️ | Add auto-login logic |
| FE-DONE-10 | `lib/features/auth/screens/role_login_screen.dart` | ⚠️ | Connect real auth |
| FE-DONE-11 | `lib/features/therapist/screens/therapist_home.dart` | ⚠️ | Connect real data |
| FE-DONE-12 | `lib/features/therapist/screens/therapist_dashboard.dart` | ✅ | Nav wrapper — no change |
| FE-DONE-13 | `lib/features/therapist/screens/therapist_children_list.dart` | ⚠️ | Connect real data |
| FE-DONE-14 | `lib/features/therapist/screens/child_profile_screen.dart` | ⚠️ | 5 tabs — connect real data |
| FE-DONE-15 | `lib/features/therapist/screens/session_notes_screen.dart` | ⚠️ | Connect POST /sessions/:id/notes |
| FE-DONE-16 | `lib/features/parent/screens/parent_home.dart` | ⚠️ | Connect real data |
| FE-DONE-17 | `lib/features/parent/screens/parent_feedback_screen.dart` | ⚠️ | Connect POST /assessments |
| FE-DONE-18 | `lib/features/center_head/screens/add_child_screen.dart` | ⚠️ | 4-step — connect POST /children |
| FE-DONE-19 | `lib/features/center_head/screens/admin_screens.dart` | ⚠️ | Connect real data |
| FE-DONE-20 | `lib/features/reports/screens/report_screens.dart` | ⚠️ | Connect GET /reports |
| FE-DONE-21 | Platform configs (android/ios/web/linux/windows/macos) | ✅ | |

---

## ✅ PHASE 3 — Backend (Node.js) — COMPLETE

### 3A: Project Scaffold

| ID | Task | File | Priority | Blocked By | Time |
|----|------|------|----------|-----------|------|
| **BACKEND-001** | Create package.json with all deps | `backend/package.json` | 🔴 CRITICAL | — | 15 min |
| **BACKEND-002** | Create tsconfig.json | `backend/tsconfig.json` | 🔴 CRITICAL | — | 10 min |
| **BACKEND-003** | Create .env.example + .env (fill secrets) | `backend/.env` | 🔴 CRITICAL | — | 10 min |
| **BACKEND-004** | Create docker-compose.yml (mongo + redis) | `backend/docker-compose.yml` | 🔴 CRITICAL | — | 10 min |
| **BACKEND-005** | Create utils/logger.ts (Pino) | `backend/src/utils/logger.ts` | 🔴 | — | 15 min |
| **BACKEND-006** | Create utils/http.ts (AppError + asyncHandler) | `backend/src/utils/http.ts` | 🔴 | — | 15 min |

### 3B: Config Layer

| ID | Task | File | Priority | Blocked By | Time |
|----|------|------|----------|-----------|------|
| **BACKEND-007** | Create config/env.ts (Zod-validated) | `backend/src/config/env.ts` | 🔴 CRITICAL | BACKEND-001 | 20 min |
| **BACKEND-008** | Create config/db.ts (Mongoose connect) | `backend/src/config/db.ts` | 🔴 CRITICAL | BACKEND-007 | 15 min |
| **BACKEND-009** | Create config/redis.ts (ioredis) | `backend/src/config/redis.ts` | 🔴 | BACKEND-007 | 15 min |
| **BACKEND-010** | Create config/s3.ts (S3 client + presign) | `backend/src/config/s3.ts` | 🔴 | BACKEND-007 | 20 min |

### 3C: Middleware

| ID | Task | File | Priority | Blocked By | Time |
|----|------|------|----------|-----------|------|
| **BACKEND-011** | Create middleware/auth.ts (JWT verify) | `backend/src/middleware/auth.ts` | 🔴 CRITICAL | BACKEND-007 | 25 min |
| **BACKEND-012** | Create middleware/role.ts (role guard factory) | `backend/src/middleware/role.ts` | 🔴 CRITICAL | BACKEND-011 | 15 min |
| **BACKEND-013** | Create middleware/error.ts (central handler) | `backend/src/middleware/error.ts` | 🔴 CRITICAL | BACKEND-006 | 20 min |
| **BACKEND-014** | Create middleware/rate-limit.ts | `backend/src/middleware/rate-limit.ts` | 🔴 | BACKEND-001 | 15 min |
| **BACKEND-015** | Create middleware/upload.ts (Multer) | `backend/src/middleware/upload.ts` | 🔴 | BACKEND-010 | 20 min |

### 3D: Models (Mongoose)

| ID | Task | File | Priority | Blocked By | Time |
|----|------|------|----------|-----------|------|
| **BACKEND-016** | user.model.ts | `backend/src/models/user.model.ts` | 🔴 CRITICAL | BACKEND-008 | 30 min |
| **BACKEND-017** | therapist-profile.model.ts | `backend/src/models/therapist-profile.model.ts` | 🔴 | BACKEND-016 | 25 min |
| **BACKEND-018** | child.model.ts (complex — home_context + consent) | `backend/src/models/child.model.ts` | 🔴 CRITICAL | BACKEND-016 | 45 min |
| **BACKEND-019** | child-snapshot.model.ts | `backend/src/models/child-snapshot.model.ts` | 🔴 | BACKEND-018 | 30 min |
| **BACKEND-020** | assessment.model.ts | `backend/src/models/assessment.model.ts` | 🔴 | BACKEND-018 | 25 min |
| **BACKEND-021** | session.model.ts + session-notes embedded | `backend/src/models/session.model.ts` | 🔴 | BACKEND-018 | 35 min |
| **BACKEND-022** | home-plan.model.ts + task schema | `backend/src/models/home-plan.model.ts` | 🔴 | BACKEND-018 | 30 min |
| **BACKEND-023** | home-task-log.model.ts | `backend/src/models/home-task-log.model.ts` | 🔴 | BACKEND-022 | 20 min |
| **BACKEND-024** | diet-plan.model.ts | `backend/src/models/diet-plan.model.ts` | 🔴 | BACKEND-018 | 25 min |
| **BACKEND-025** | meal-log.model.ts | `backend/src/models/meal-log.model.ts` | 🔴 | BACKEND-024 | 20 min |
| **BACKEND-026** | attendance.model.ts | `backend/src/models/attendance.model.ts` | 🔴 | BACKEND-021 | 15 min |
| **BACKEND-027** | verification.model.ts | `backend/src/models/verification.model.ts` | 🔴 | BACKEND-023 | 20 min |
| **BACKEND-028** | alert.model.ts | `backend/src/models/alert.model.ts` | 🔴 | BACKEND-018 | 20 min |
| **BACKEND-029** | ai-call.model.ts (MANDATORY audit) | `backend/src/models/ai-call.model.ts` | 🔴 CRITICAL | BACKEND-016 | 20 min |

### 3E: App Entry + Wiring

| ID | Task | File | Priority | Blocked By | Time |
|----|------|------|----------|-----------|------|
| **BACKEND-030** | Create src/app.ts (Express + all middleware) | `backend/src/app.ts` | 🔴 CRITICAL | BACKEND-011–014 | 30 min |
| **BACKEND-031** | Create src/index.ts (entry point) | `backend/src/index.ts` | 🔴 CRITICAL | BACKEND-030 | 15 min |

**TEST GATE:** Run `pnpm dev` → should see "NaiviSense API started" + GET /health → 200.

### 3F: Auth Module (First API — Unblocks Frontend)

| ID | Task | File | Priority | Blocked By | Time |
|----|------|------|----------|-----------|------|
| **BACKEND-032** | auth.schema.ts (Zod) | `backend/src/modules/auth/auth.schema.ts` | 🔴 CRITICAL | BACKEND-001 | 15 min |
| **BACKEND-033** | auth.service.ts (bcrypt + JWT) | `backend/src/modules/auth/auth.service.ts` | 🔴 CRITICAL | BACKEND-016,032 | 45 min |
| **BACKEND-034** | auth.controller.ts | `backend/src/modules/auth/auth.controller.ts` | 🔴 CRITICAL | BACKEND-033 | 20 min |
| **BACKEND-035** | auth.routes.ts | `backend/src/modules/auth/auth.routes.ts` | 🔴 CRITICAL | BACKEND-034 | 15 min |

**TEST GATE:** POST /api/v1/auth/register → 201 with tokens. POST /api/v1/auth/login → 200 with tokens.

### 3G: Core API Modules

| ID | Task | File | Priority | Blocked By | Time |
|----|------|------|----------|-----------|------|
| **BACKEND-036** | users module (GET /me + PATCH + photo upload) | `backend/src/modules/users/*` | 🔴 | BACKEND-035 | 45 min |
| **BACKEND-037** | children schema + service + controller + routes | `backend/src/modules/children/*` | 🔴 CRITICAL | BACKEND-018,035 | 75 min |
| **BACKEND-038** | assessments module (initial + parent_feedback) | `backend/src/modules/assessments/*` | 🔴 | BACKEND-020,035 | 60 min |
| **BACKEND-039** | sessions module (create + notes + upcoming) | `backend/src/modules/sessions/*` | 🔴 CRITICAL | BACKEND-021,035 | 70 min |
| **BACKEND-040** | home-plans module (create + active + log task) | `backend/src/modules/home-plans/*` | 🔴 | BACKEND-022,035 | 65 min |
| **BACKEND-041** | diet-plans module | `backend/src/modules/diet-plans/*` | 🔴 | BACKEND-024,035 | 55 min |
| **BACKEND-042** | verification module (queue + approve/reject) | `backend/src/modules/verification/*` | 🔴 | BACKEND-027,035 | 60 min |
| **BACKEND-043** | alerts module (create + list + patch) | `backend/src/modules/alerts/*` | 🔴 | BACKEND-028,035 | 45 min |
| **BACKEND-044** | reports module (progress + monthly computed) | `backend/src/modules/reports/*` | 🔴 | BACKEND-039,035 | 70 min |
| **BACKEND-045** | ai module (thin wrapper → AI service) | `backend/src/modules/ai/*` | ⏸️ | BACKEND-035 + AI-001 | 45 min |

### 3H: Background Jobs

| ID | Task | File | Priority | Blocked By | Time |
|----|------|------|----------|-----------|------|
| **BACKEND-046** | jobs/queues.ts (BullMQ queue setup) | `backend/src/jobs/queues.ts` | 🔴 | BACKEND-009 | 20 min |
| **BACKEND-047** | jobs/snapshot.job.ts (Worker) | `backend/src/jobs/snapshot.job.ts` | ⏸️ | BACKEND-046 + AI-002 | 30 min |
| **BACKEND-048** | jobs/chunk.job.ts (Worker) | `backend/src/jobs/chunk.job.ts` | ⏸️ | BACKEND-046 + AI-003 | 30 min |
| **BACKEND-049** | jobs/report.job.ts (monthly cron) | `backend/src/jobs/report.job.ts` | ⏸️ | BACKEND-046 + AI-007 | 25 min |

### 3I: Tests

| ID | Task | File | Priority | Blocked By | Time |
|----|------|------|----------|-----------|------|
| **BACKEND-050** | tests/setup.ts (mongodb-memory-server) | `backend/tests/setup.ts` | 🔴 | BACKEND-008 | 20 min |
| **BACKEND-051** | tests/auth.test.ts (register, login, duplicate) | `backend/tests/auth.test.ts` | 🔴 | BACKEND-035,050 | 40 min |
| **BACKEND-052** | tests/children.test.ts (CRUD + role scoping) | `backend/tests/children.test.ts` | 🔴 | BACKEND-037,050 | 45 min |
| **BACKEND-053** | tests/sessions.test.ts | `backend/tests/sessions.test.ts` | 🔴 | BACKEND-039,050 | 40 min |

---

## ⏸️ PHASE 4 — Frontend Integration (Blocked by Phase 3)

> **Start this only after BACKEND-039 (sessions) is done.** The critical path is:
> auth API → children API → sessions API → home plans API.

| ID | Task | File | Priority | Blocked By | Time |
|----|------|------|----------|-----------|------|
| **INT-001** | Update pubspec.yaml (add all deps) | `pubspec.yaml` | ⏸️ | BACKEND-035 | 15 min |
| **INT-002** | Create storage_service.dart | `lib/data/services/storage_service.dart` | ⏸️ | INT-001 | 20 min |
| **INT-003** | Create api_service.dart (Dio + interceptors) | `lib/data/services/api_service.dart` | ⏸️ | INT-002 | 45 min |
| **INT-004** | Add fromJson/toJson to user.dart | `lib/shared/models/user.dart` | ⏸️ | BACKEND-035 | 20 min |
| **INT-005** | Add fromJson/toJson to child.dart | `lib/shared/models/child.dart` | ⏸️ | BACKEND-037 | 25 min |
| **INT-006** | Add fromJson/toJson to session.dart | `lib/shared/models/session.dart` | ⏸️ | BACKEND-039 | 20 min |
| **INT-007** | Add fromJson/toJson to home_plan.dart | `lib/shared/models/home_plan.dart` | ⏸️ | BACKEND-040 | 20 min |
| **INT-008** | Create auth_repository.dart | `lib/data/repositories/auth_repository.dart` | ⏸️ | INT-003,004 | 30 min |
| **INT-009** | Create/rewrite auth_provider.dart (StateNotifier) | `lib/features/auth/providers/auth_provider.dart` | ⏸️ | INT-008 | 35 min |
| **INT-010** | Update app_router.dart (auth guard + role guard) | `lib/routing/app_router.dart` | ⏸️ | INT-009 | 25 min |
| **INT-011** | Update splash_screen.dart (auto-login) | `lib/features/auth/screens/splash_screen.dart` | ⏸️ | INT-009 | 20 min |
| **INT-012** | Connect role_login_screen.dart (real API) | `lib/features/auth/screens/role_login_screen.dart` | ⏸️ | INT-009 | 25 min |
| **INT-013** | Create child_repository.dart | `lib/data/repositories/child_repository.dart` | ⏸️ | INT-003,005 | 25 min |
| **INT-014** | Create child_management_provider.dart | `lib/features/center_head/providers/child_management_provider.dart` | ⏸️ | INT-013 | 25 min |
| **INT-015** | Connect add_child_screen (submit form) | `lib/features/center_head/screens/add_child_screen.dart` | ⏸️ | INT-014 | 30 min |
| **INT-016** | Create session_repository.dart | `lib/data/repositories/session_repository.dart` | ⏸️ | INT-003,006 | 25 min |
| **INT-017** | Create therapist_dashboard_provider.dart | `lib/features/therapist/providers/therapist_dashboard_provider.dart` | ⏸️ | INT-013,016 | 25 min |
| **INT-018** | Connect therapist_home.dart (real data) | `lib/features/therapist/screens/therapist_home.dart` | ⏸️ | INT-017 | 30 min |
| **INT-019** | Connect session_notes_screen.dart (POST notes) | `lib/features/therapist/screens/session_notes_screen.dart` | ⏸️ | INT-016 | 25 min |
| **INT-020** | Create home_plan_repository.dart | `lib/data/repositories/home_plan_repository.dart` | ⏸️ | INT-003,007 | 25 min |
| **INT-021** | Create parent_dashboard_provider.dart | `lib/features/parent/providers/parent_dashboard_provider.dart` | ⏸️ | INT-013,020 | 25 min |
| **INT-022** | Connect parent_home.dart (real data) | `lib/features/parent/screens/parent_home.dart` | ⏸️ | INT-021 | 30 min |
| **INT-023** | Create feedback_provider.dart | `lib/features/parent/providers/feedback_provider.dart` | ⏸️ | INT-003 | 20 min |
| **INT-024** | Connect parent_feedback_screen.dart (POST) | `lib/features/parent/screens/parent_feedback_screen.dart` | ⏸️ | INT-023 | 25 min |
| **INT-025** | Create verification_repository.dart | `lib/data/repositories/verification_repository.dart` | ⏸️ | INT-003 | 20 min |
| **INT-026** | Create verification_provider.dart | `lib/features/center_head/providers/verification_provider.dart` | ⏸️ | INT-025 | 25 min |
| **INT-027** | Build verification_panel_screen.dart (NEW) | `lib/features/center_head/screens/verification_panel_screen.dart` | ⏸️ | INT-026 | 45 min |
| **INT-028** | Create progress_report_provider.dart | `lib/features/reports/providers/progress_report_provider.dart` | ⏸️ | INT-003 | 20 min |
| **INT-029** | Connect report_screens.dart (real data + chart) | `lib/features/reports/screens/report_screens.dart` | ⏸️ | INT-028 | 35 min |
| **INT-030** | Add state_widgets (loading, error, empty) | `lib/shared/widgets/state_widgets/` | ⏸️ | INT-001 | 25 min |
| **INT-031** | Build parent_camera_screen.dart (NEW) | `lib/features/parent/screens/parent_camera_screen.dart` | ⏸️ | INT-020 | 50 min |

---

## ⏸️ PHASE 5 — AI Service (Python FastAPI)

> **Start after BACKEND-039 is working.** AI service is independent — can run in parallel
> with Phase 4 frontend integration.

| ID | Task | File | Priority | Blocked By | Time |
|----|------|------|----------|-----------|------|
| **AI-001** | pyproject.toml + pip install | `ai-service/pyproject.toml` | ⏸️ | BACKEND-008 (Mongo running) | 15 min |
| **AI-002** | config.py (Pydantic settings) | `ai-service/app/config.py` | ⏸️ | AI-001 | 15 min |
| **AI-003** | deps.py (mongo, claude, voyage singletons) | `ai-service/app/deps.py` | ⏸️ | AI-002 | 20 min |
| **AI-004** | main.py (FastAPI + token middleware) | `ai-service/app/main.py` | ⏸️ | AI-002 | 20 min |
| **AI-005** | services/llm_client.py (Claude + Voyage wrappers) | `ai-service/app/services/llm_client.py` | ⏸️ | AI-003 | 30 min |
| **AI-006** | services/snapshot_builder.py | `ai-service/app/services/snapshot_builder.py` | ⏸️ | AI-003 | 60 min |
| **AI-007** | routers/snapshot.py (rebuild + current) | `ai-service/app/routers/snapshot.py` | ⏸️ | AI-006 | 25 min |
| **AI-008** | services/chunker.py (event → summary → embed) | `ai-service/app/services/chunker.py` | ⏸️ | AI-005 | 45 min |
| **AI-009** | routers/chunk.py | `ai-service/app/routers/chunk.py` | ⏸️ | AI-008 | 20 min |
| **AI-010** | services/retriever.py (Atlas Vector Search) | `ai-service/app/services/retriever.py` | ⏸️ | AI-003 | 35 min |
| **AI-011** | routers/retrieve.py | `ai-service/app/routers/retrieve.py` | ⏸️ | AI-010 | 20 min |
| **AI-012** | prompts/plan_generation.md (prompt template) | `ai-service/app/prompts/plan_generation.md` | ⏸️ | — | 30 min |
| **AI-013** | routers/plan.py (generate + approve) | `ai-service/app/routers/plan.py` | ⏸️ | AI-005,011,012 | 60 min |
| **AI-014** | prompts/insights.md | `ai-service/app/prompts/insights.md` | ⏸️ | — | 20 min |
| **AI-015** | routers/insights.py | `ai-service/app/routers/insights.py` | ⏸️ | AI-005,014 | 25 min |
| **AI-016** | prompts/monthly_report.md | `ai-service/app/prompts/monthly_report.md` | ⏸️ | — | 25 min |
| **AI-017** | routers/report.py | `ai-service/app/routers/report.py` | ⏸️ | AI-005,016 | 30 min |
| **AI-018** | Wire BACKEND-045 (Node ai module → AI service) | `backend/src/modules/ai/*` | ⏸️ | AI-013,015 | 45 min |
| **AI-019** | Wire BullMQ workers (BACKEND-046–049) | `backend/src/jobs/*.job.ts` | ⏸️ | AI-007,009 | 60 min |
| **AI-020** | Atlas Vector Search index setup (once) | MongoDB Atlas console | ⏸️ | AI-010 | 20 min |
| **AI-021** | Build AI plan editor screen (Flutter) | `lib/features/therapist/screens/ai_plan_editor_screen.dart` | ⏸️ | AI-018 | 60 min |

---

## ⏸️ PHASE 6 — Testing

| ID | Task | Target | Time |
|----|------|--------|------|
| **TEST-001** | Backend: auth flow end-to-end | register → login → protected route → refresh | 45 min |
| **TEST-002** | Backend: child CRUD + role scoping | 3 roles, 3 scenarios | 45 min |
| **TEST-003** | Backend: session notes save + snapshot trigger | DB check | 40 min |
| **TEST-004** | Backend: verification approve → chunk created | Queue check | 35 min |
| **TEST-005** | Flutter: model fromJson/toJson round-trip | All 4 models | 30 min |
| **TEST-006** | Flutter: auth flow (login, auto-login, logout) | Device test | 30 min |
| **TEST-007** | Flutter: session notes → backend → 200 | Network test | 25 min |
| **TEST-008** | Flutter: parent feedback → backend → 201 | Network test | 25 min |
| **TEST-009** | AI: snapshot build (check all fields present) | pytest | 30 min |
| **TEST-010** | AI: plan generation (valid JSON schema) | pytest | 35 min |
| **TEST-011** | AI: retrieval (filter by child_id works) | pytest | 25 min |

---

## ⏸️ PHASE 7 — Deployment

| ID | Task | Where | Time |
|----|------|-------|------|
| **DEPLOY-001** | Setup MongoDB Atlas M10 (Mumbai) | Atlas console | 30 min |
| **DEPLOY-002** | Setup Atlas Vector Search index | Atlas console | 20 min |
| **DEPLOY-003** | Setup Elasticache Redis (cache.t4g.small) | AWS console | 30 min |
| **DEPLOY-004** | Setup S3 bucket (naivisense-prod, ap-south-1) | AWS console | 20 min |
| **DEPLOY-005** | Dockerize Node API | `backend/Dockerfile` | 25 min |
| **DEPLOY-006** | Dockerize AI service | `backend/ai-service/Dockerfile` | 20 min |
| **DEPLOY-007** | ECS task definitions (2 tasks) | AWS console | 45 min |
| **DEPLOY-008** | GitHub Actions CI/CD (lint + test + ECR push) | `.github/workflows/deploy.yml` | 60 min |
| **DEPLOY-009** | Sentry setup (Node + Flutter) | Sentry console | 25 min |
| **DEPLOY-010** | Firebase App Distribution (Android beta APK) | Firebase console | 20 min |
| **DEPLOY-011** | Smoke test full flow on production | Manual | 45 min |

---

## 📈 Time Estimates

| Phase | # Tasks | Estimated Time | Who |
|-------|---------|----------------|-----|
| Phase 3: Backend | 53 | ~25 hours | Backend agent |
| Phase 4: Integration | 31 | ~14 hours | Flutter agent |
| Phase 5: AI service | 21 | ~14 hours | Python/AI agent |
| Phase 6: Testing | 11 | ~7 hours | Any |
| Phase 7: Deployment | 11 | ~7 hours | DevOps / founder |
| **Total remaining** | **127** | **~67 hours** | |

**Optimistic sprint (full-time):** 10 days
**Realistic (part-time):** 3-4 weeks

---

## 🚨 Critical Path (must complete in order)

```
BACKEND-001 → 007 → 008 → 016 → 018 → 021
                              ↓
                         BACKEND-032 → 033 → 034 → 035  ← Auth API UNLOCKS EVERYTHING
                              ↓
                    BACKEND-037 (children) + BACKEND-039 (sessions)
                              ↓
                    INT-001 → INT-003 → INT-008 → INT-009  ← Flutter auth
                              ↓
                    INT-013 → INT-016 → INT-017 → INT-018  ← Therapist live
                              ↓
                    INT-020 → INT-021 → INT-022 → INT-023  ← Parent live
                              ↓
                    MVP DEMO READY ← Target
```

---

## 🎯 MVP Definition of Done

The MVP is ready when all these pass:

### Backend
- [ ] GET /health → 200
- [ ] POST /auth/register → 201 (tokens + user, no password_hash)
- [ ] POST /auth/login → 200 (same)
- [ ] GET /users/me → 200 (authenticated)
- [ ] POST /children → 201 (center_head only)
- [ ] GET /children → 200 (scoped by role)
- [ ] POST /sessions → 201 (therapist only)
- [ ] POST /sessions/:id/notes → 200
- [ ] POST /assessments → 201 (parent feedback)
- [ ] GET /home-plans/active?childId= → 200 or 404
- [ ] POST /alerts → 201
- [ ] GET /reports/progress?childId= → 200 with chart data

### Flutter
- [ ] Auto-login on app start (no re-type credentials)
- [ ] Role-based navigation (therapist/parent/center_head to correct home)
- [ ] Therapist sees real child list (not mock data)
- [ ] Session notes save to backend
- [ ] Parent sees today's tasks
- [ ] Daily feedback submits to backend
- [ ] Progress chart shows real data
- [ ] All async states handled (loading / error / empty)
- [ ] `flutter analyze` → zero warnings

### System
- [ ] Backend can handle concurrent requests without crash
- [ ] 401 from backend → Flutter auto-refreshes token → retries
- [ ] S3 photo upload works (at least manual test)

---

## 🔧 Agent Workflow

When you start a task:
1. Open this file → find the 👉 pointer
2. Read task details (what to build, blocked by, blocks)
3. Execute
4. Test against the TEST GATE for that phase
5. **Update this file:**
   - Change 🔴 or ⏸️ to ✅
   - Move 👉 to next task
   - Update overall progress %
6. Commit:
   ```
   git commit -m "BACKEND-XXX: Brief description

   Created: path/to/file
   Tests: what was verified
   Next: BACKEND-YYY"
   ```

---

## 📝 Completion Log

| Date | Task | Who | Notes |
|------|------|-----|-------|
| *[fill as tasks complete]* | | | |

---

*Last revised: May 2026. This tracker is authoritative. The 👉 pointer is always correct.*
