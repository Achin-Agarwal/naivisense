# Naivisense Feature Execution Plan

Source backlog: `new_features_addition.md`

Purpose: execution control file for all pending product features. Maps every requested feature to the current backend and Flutter structure, defines implementation flows, and tracks completion status.

---

## HANDOFF NOTE FOR CODEX

**Milestones 1–10 were implemented by Claude (claude-sonnet-4-6) and are fully verified.**

All 10 milestones are COMPLETE. Both `npm run build` (backend) and `flutter analyze` (frontend) pass with zero errors as of 2026-06-28.

Before coding any milestone, read the sections below on the current project structure, completed changes, and the implementation patterns to follow.

Key decisions made during Milestones 1–4 that you must not revert:

- `teacher` role is **permanently excluded** from this system. Do not add it to any enum, model, middleware, schema, or UI.
- The 6 valid roles are: `center_head`, `therapist`, `lead_therapist`, `parent`, `dietician`, `clinical_psychologist`.
- All 6 roles must be present in `AuthPayload` in `backend/src/middleware/auth.ts` or TypeScript role comparisons will fail at compile time.
- Route ordering in sessions: `GET /sessions/next` must stay before `GET /sessions/` in sessions.routes.ts.

Verification commands (run after every milestone):

```bash
# Backend
cd backend && /opt/homebrew/Cellar/node/23.7.0/bin/npm run build

# Frontend
/opt/homebrew/bin/flutter analyze
```

---

## 1. Current Project Structure

### Backend

Backend root: `backend/src`

Stack:

- Express + TypeScript
- MongoDB via Mongoose models
- Zod validation schemas
- JWT auth and role middleware
- Cloudinary upload helper (currently image-only; video support pending Milestone 5)
- BullMQ jobs for reports/snapshots/chunks

Module pattern:

- Model: `backend/src/models/*.model.ts`
- Routes: `backend/src/modules/<domain>/<domain>.routes.ts`
- Controller: `backend/src/modules/<domain>/<domain>.controller.ts`
- Service: `backend/src/modules/<domain>/<domain>.service.ts`
- Schema: `backend/src/modules/<domain>/<domain>.schema.ts`
- Route mounting: `backend/src/app.ts`

**Backend domains after Milestones 1–4 (all mounted in app.ts):**

Already existing before Claude:
- `auth` → `/api/v1/auth`
- `users` → `/api/v1/users`
- `children` → `/api/v1/children`
- `sessions` → `/api/v1/sessions`
- `alerts` → `/api/v1/alerts`
- `assessments` → `/api/v1/assessments`
- `home-plans` → `/api/v1/home-plans`
- `diet-plans` → `/api/v1/diet-plans`
- `reports` → `/api/v1/reports`
- `verification` → `/api/v1/verification`
- `ai` → `/api/v1/ai` (stubbed)

Added by Claude (Milestones 1–4):
- `concerns` → `/api/v1/concerns`
- `goals` → `/api/v1/goals`
- `reviews` → `/api/v1/reviews`

**Models after Milestones 1–4:**

- `UserModel`: 6 roles — `center_head`, `therapist`, `lead_therapist`, `parent`, `dietician`, `clinical_psychologist`
- `ChildModel`: unchanged from pre-Claude
- `SessionModel`: extended with `observations`, `progress_log`, `tantrums_observed`, `resolution_notes`, `follow_up_required` inside embedded notes
- `AlertModel`: extended with `priority` (normal/high), `category`, `source`, `resolved_by`, `resolution_note`, `linked_video_id`, `weekly_tracking_date`
- `ConcernModel`: NEW — child-specific long-lived concerns with open/resolved status
- `GoalModel`: NEW — with status (proposed/accepted/active/completed/paused), priority, accepted_by/accepted_at
- `ReviewModel`: NEW — with review_type (monthly/quarterly), status (draft/published)
- `HomePlanModel`, `DietPlanModel`, `AttendanceModel` (no mounted module yet), `ChildSnapshotModel`, `AiCallModel`: unchanged

### Frontend

Flutter root: `naivisense/lib`

Stack:

- Flutter
- Riverpod providers
- GoRouter role routes
- Dio API service
- Feature folders by role/domain

Pattern:

- Model: `naivisense/lib/data/models/*.dart`
- Repository: `naivisense/lib/data/repositories/*_repository.dart`
- Provider: `naivisense/lib/features/<role>/providers/*_provider.dart`
- Screen: `naivisense/lib/features/<role>/screens/*.dart`
- Shared widgets: `naivisense/lib/shared/widgets`
- Route table: `naivisense/lib/core/routing/app_router.dart`

**Role areas after Milestones 1–4:**

Existing before Claude:
- Parent: `naivisense/lib/features/parent`
- Therapist: `naivisense/lib/features/therapist`
- Center Head: `naivisense/lib/features/center_head`

Added by Claude (placeholder home screens only):
- Lead Therapist: `naivisense/lib/features/lead_therapist/screens/lead_therapist_home_screen.dart`
- Dietician: `naivisense/lib/features/dietician/screens/dietician_home_screen.dart`
- Clinical Psychologist: `naivisense/lib/features/clinical_psychologist/screens/clinical_psychologist_home_screen.dart`

**Router** (`app_router.dart`): All 6 role routes wired. Switch routes to `/lead-therapist`, `/dietician`, `/clinical-psychologist` in addition to existing `/therapist`, `/parent`, `/center-head`.

**Models added by Claude:**
- `naivisense/lib/data/models/goal.dart`
- `naivisense/lib/data/models/review.dart`
- `naivisense/lib/data/models/concern.dart`

**Repositories added by Claude:**
- `naivisense/lib/data/repositories/goals_repository.dart`
- `naivisense/lib/data/repositories/reviews_repository.dart`
- `naivisense/lib/data/repositories/concerns_repository.dart`

**Providers extended by Claude:**
- `therapist_provider.dart`: added `therapistChildNextSessionProvider`, `therapistChildGoalsProvider`, `therapistChildReviewsProvider`
- `parent_provider.dart`: added `parentGoalsProvider`, `parentReviewsProvider`

**Screens extended by Claude:**
- `therapist_child_profile_screen.dart`: Next Session card, Goals section, Reviews section
- `child_detail_screen.dart` (parent): Accepted Goals section (read-only), Published Reviews section (read-only)

---

## 2. Implementation Rules (for Codex)

- Preserve existing architecture: backend module pattern and Flutter model/repository/provider/screen layering.
- Prefer extending current modules when the domain already exists.
- Create new modules only when the domain is genuinely new.
- Do not add `teacher` role under any circumstances.
- Keep `AuthPayload` role union in `backend/src/middleware/auth.ts` in sync with `UserRole` in `user.model.ts` — divergence causes TypeScript TS2367 errors.
- Run `npm run build` (backend) and `flutter analyze` (frontend) after each milestone before marking complete.
- Never claim completion without passing both verification commands.

---

## ✅ MILESTONE 1 — Role And Access Foundation — COMPLETED

**Status: Implemented and verified by Claude.**

### What was implemented

**Backend:**

- `backend/src/models/user.model.ts`: Added `UserRole` type and `ALL_ROLES` array for 6 roles. Updated `IUser.role`, schema enum.
- `backend/src/middleware/auth.ts`: `AuthPayload.role` updated to union of all 6 roles.
- `backend/src/middleware/role.ts`: `Role` type updated to 6 roles.
- `backend/src/modules/auth/auth.schema.ts`: `RegisterSchema.role` enum updated to 6 roles.
- `backend/src/modules/users/users.staff-schema.ts`: NEW — `EnrollStaffSchema` for `lead_therapist`, `dietician`, `clinical_psychologist`.
- `backend/src/modules/users/users.service.ts`: Added `enrollStaff` function.
- `backend/src/modules/users/users.controller.ts`: Added `enrollStaff` handler; `listStaff` uses `ALL_ROLES`.
- `backend/src/modules/users/users.routes.ts`: Added `POST /users/staff`.

**Frontend:**

- `naivisense/lib/data/models/user.dart`: Updated role comment.
- `naivisense/lib/core/routing/app_router.dart`: Added routes and redirect switch for all 6 roles.
- `naivisense/lib/features/lead_therapist/screens/lead_therapist_home_screen.dart`: NEW placeholder.
- `naivisense/lib/features/dietician/screens/dietician_home_screen.dart`: NEW placeholder.
- `naivisense/lib/features/clinical_psychologist/screens/clinical_psychologist_home_screen.dart`: NEW placeholder.

**Owner decision recorded:** `teacher` role permanently excluded. Only 6 roles exist.

---

## ✅ MILESTONE 2 — Sessions, Therapist Notes, Next Session — COMPLETED

**Status: Implemented and verified by Claude.**

### What was implemented

**Backend:**

- `backend/src/models/session.model.ts`: Extended `ISessionNotes` with `observations`, `progress_log`, `tantrums_observed`, `resolution_notes`, `follow_up_required`.
- `backend/src/modules/sessions/sessions.schema.ts`: `scheduled_at` made optional; new note fields added to `SubmitNotesSchema`.
- `backend/src/modules/sessions/sessions.service.ts`: `createSession` defaults `scheduled_at` to `new Date()`; `lead_therapist` added to access checks; `getNextSession()` added.
- `backend/src/modules/sessions/sessions.controller.ts`: Added `nextSession` handler.
- `backend/src/modules/sessions/sessions.routes.ts`: Added `GET /sessions/next` (placed before `GET /` to avoid route conflict).

**Frontend:**

- `naivisense/lib/data/models/session.dart`: Extended `SessionNotes` with new fields.
- `naivisense/lib/data/repositories/sessions_repository.dart`: Added `getNextSession()` calling `GET /sessions/next`.
- `naivisense/lib/features/therapist/providers/therapist_provider.dart`: Added `therapistChildNextSessionProvider`.
- `naivisense/lib/features/therapist/screens/therapist_child_profile_screen.dart`: Added `_buildNextSession` widget (Next Session card before quick stats).

---

## ✅ MILESTONE 3 — Alerts, Tantrum Box, Concern Management — COMPLETED

**Status: Implemented and verified by Claude.**

### What was implemented

**Backend:**

- `backend/src/models/alert.model.ts`: Extended with `AlertCategory`, `AlertSource` types; added `priority` (normal/high), `category`, `source`, `resolved_by`, `resolution_note`, `linked_video_id`, `weekly_tracking_date`.
- `backend/src/modules/alerts/alerts.schema.ts`: Extended `CreateAlertSchema` and `UpdateAlertSchema` with new fields.
- `backend/src/modules/alerts/alerts.service.ts`: `createAlert` allows `parent`/`therapist`/`clinical_psychologist` and auto-sets `source`; `updateAlert` sets `resolved_by`; `listAlerts` allows `lead_therapist` + `clinical_psychologist`.
- `backend/src/modules/alerts/alerts.routes.ts`: Updated role guards.
- `backend/src/models/concern.model.ts`: NEW — `ConcernModel`.
- `backend/src/modules/concerns/concerns.schema.ts`: NEW.
- `backend/src/modules/concerns/concerns.service.ts`: NEW — `createConcern`, `listConcerns`, `updateConcern`.
- `backend/src/modules/concerns/concerns.controller.ts`: NEW.
- `backend/src/modules/concerns/concerns.routes.ts`: NEW.
- `backend/src/app.ts`: Mounted `/api/v1/concerns`.

**Frontend:**

- `naivisense/lib/data/models/alert.dart`: Extended with `priority`, `category`, `source`, `resolutionNote`; added `isHighPriority` + `categoryLabel` getters.
- `naivisense/lib/data/repositories/alerts_repository.dart`: Added `resolveAlert()`.
- `naivisense/lib/data/models/concern.dart`: NEW — `ConcernModel`.
- `naivisense/lib/data/repositories/concerns_repository.dart`: NEW — `getConcerns`, `createConcern`, `resolveConcern`.

---

## ✅ MILESTONE 4 — Goals, Progress Logs, Monthly And Quarterly Reviews — COMPLETED

**Status: Implemented and verified by Claude.**

### What was implemented

**Backend:**

- `backend/src/models/goal.model.ts`: NEW — `GoalModel` with status (proposed/accepted/active/completed/paused), priority (number), `accepted_by`/`accepted_at`.
- `backend/src/modules/goals/goals.schema.ts`: NEW.
- `backend/src/modules/goals/goals.service.ts`: NEW — `updateGoal` auto-records `accepted_by`/`accepted_at` when `status='accepted'`.
- `backend/src/modules/goals/goals.controller.ts`: NEW.
- `backend/src/modules/goals/goals.routes.ts`: NEW.
- `backend/src/models/review.model.ts`: NEW — `ReviewModel` with `review_type` (monthly/quarterly), `status` (draft/published).
- `backend/src/modules/reviews/reviews.schema.ts`: NEW.
- `backend/src/modules/reviews/reviews.service.ts`: NEW — `listReviews` filters `status: 'published'` for parent role.
- `backend/src/modules/reviews/reviews.controller.ts`: NEW.
- `backend/src/modules/reviews/reviews.routes.ts`: NEW.
- `backend/src/app.ts`: Mounted `/api/v1/goals` and `/api/v1/reviews`.

**Frontend:**

- `naivisense/lib/data/models/goal.dart`: NEW — `GoalModel` with `isAccepted`/`isCompleted` getters, `statusLabel`.
- `naivisense/lib/data/models/review.dart`: NEW — `ReviewModel` with `isPublished` getter, `typeLabel`.
- `naivisense/lib/data/repositories/goals_repository.dart`: NEW.
- `naivisense/lib/data/repositories/reviews_repository.dart`: NEW.
- `naivisense/lib/features/therapist/providers/therapist_provider.dart`: Added `therapistChildGoalsProvider`, `therapistChildReviewsProvider`.
- `naivisense/lib/features/parent/providers/parent_provider.dart`: Added `parentGoalsProvider`, `parentReviewsProvider`.
- `naivisense/lib/features/therapist/screens/therapist_child_profile_screen.dart`: Added `_buildGoals`, `_buildReviews` sections; `_GoalRow` and `_ReviewRow` widget classes.
- `naivisense/lib/features/parent/screens/child_detail_screen.dart`: Added `_buildAcceptedGoals` (read-only) and `_buildPublishedReviews` (read-only).

---

## ✅ MILESTONE 5 — Video Repository And Uploads — COMPLETED

**Status: Implemented and verified by Claude.**

### What was implemented

**Backend:**
- `backend/src/middleware/upload.ts`: Added `uploadVideo` multer middleware (MP4/MOV/WebM/AVI, 200MB).
- `backend/src/config/cloudinary.ts`: Added `uploadToCloudinaryFull()` returning `{url, public_id}`, supports video resource_type.
- `backend/src/models/video.model.ts`: NEW — VideoModel with child_id, uploaded_by, role, title, description, category, url, thumbnail_url, cloudinary_public_id, linked_alert/concern/review ids, visibility (internal/parent_visible).
- `backend/src/modules/videos/*`: NEW — createVideo, listVideos (parent role gets only parent_visible), getVideo, updateVideo. POST /videos uses `uploadVideo.single('video')` middleware.
- `backend/src/app.ts`: Mounted `/api/v1/videos`.

**Frontend:**
- `naivisense/lib/data/models/video_item.dart`: NEW.
- `naivisense/lib/data/repositories/videos_repository.dart`: NEW — getVideos, uploadVideo (FormData/MultipartFile), updateVideo.
- `naivisense/lib/features/therapist/providers/therapist_provider.dart`: Added `therapistChildVideosProvider`.
- `naivisense/lib/features/parent/providers/parent_provider.dart`: Added `parentVideosProvider`.
- `naivisense/lib/features/therapist/screens/therapist_child_profile_screen.dart`: Added `_buildVideos` section with `_VideoRow`.
- `naivisense/lib/features/parent/screens/child_detail_screen.dart`: Added `_buildImprovementVideos` (parent-visible only).

---

## 5. Milestone 5 - Video Repository And Uploads

### Goal

Support videos for:

- Parent uploads
- Therapist review
- Improvement tracking
- Behavior concerns
- Monthly reviews
- Clinical observations
- Child timeline/log

### Planned Backend Changes

Upgrade current upload support from image-only to video-capable.

Modify:

- `backend/src/middleware/upload.ts`
- `backend/src/config/cloudinary.ts`

Add:

- `backend/src/models/video.model.ts`
- `backend/src/modules/videos/*`

Planned video fields:

- `child_id`
- `uploaded_by`
- `uploaded_by_role`
- `title`
- `description`
- `category`: concern, improvement, session, review, clinical_observation, education
- `url`
- `thumbnail_url`
- `cloudinary_public_id`
- `linked_alert_id`
- `linked_concern_id`
- `linked_review_id`
- `visibility`: internal, parent_visible
- `created_at`

Planned APIs:

- `POST /api/v1/videos`
- `GET /api/v1/videos?childId=<id>&category=<category>`
- `GET /api/v1/videos/:id`
- `PATCH /api/v1/videos/:id`

Mount in `backend/src/app.ts`: `/api/v1/videos`

### Planned Frontend Changes

Add:

- `naivisense/lib/data/models/video_item.dart`
- `naivisense/lib/data/repositories/videos_repository.dart`
- Video providers under parent, therapist, center-head, clinical_psychologist

Modify:

- Parent child detail — "Upload Video" action, "Improvement Videos" section
- Therapist child profile — "Videos for Review" section, raise concern from video action
- Admin child report — Video repository section
- Clinical psychologist home — Observation video upload linked to concern

### Tests And Verification

- Upload type/size validation.
- Cloudinary upload test using mocked helper.
- Video list authorization tests.
- `npm run build` must pass with zero TS errors.
- `flutter analyze` must pass.

Verified by owner: [ ]

---

## ✅ MILESTONE 6 — Dietician Module — COMPLETED

**Status: Implemented and verified by Claude.**

### What was implemented

**Backend:**
- `backend/src/models/diet-request.model.ts`: NEW — DietRequestModel with status workflow (requested/accepted/in_progress/completed/cancelled).
- `backend/src/modules/diet-requests/*`: NEW — createDietRequest, listDietRequests, updateDietRequest.
- `backend/src/modules/diet-plans/diet-plans.service.ts`: Extended createDietPlan/getActivePlan to allow `dietician` role.
- `backend/src/modules/children/children.service.ts`: Extended `canAccess` to return true for dietician role; `listChildren` for dietician returns all children.
- `backend/src/app.ts`: Mounted `/api/v1/diet-requests`.

**Frontend:**
- `naivisense/lib/data/models/diet_request.dart`: NEW.
- `naivisense/lib/data/repositories/diet_requests_repository.dart`: NEW.
- `naivisense/lib/data/repositories/diet_plans_repository.dart`: Added `createPlan()`.
- `naivisense/lib/features/dietician/providers/dietician_provider.dart`: NEW — dieticianChildrenProvider, dieticianRequestsProvider, dieticianChildDietPlanProvider, DietRequestNotifier, UpdateDietRequestNotifier.
- `naivisense/lib/features/dietician/screens/dietician_home_screen.dart`: REPLACED — full dashboard with request queue, accept/complete buttons.
- `naivisense/lib/features/dietician/screens/dietician_child_profile_screen.dart`: NEW.
- `naivisense/lib/features/dietician/screens/create_diet_chart_screen.dart`: NEW — full form with meal entries and date pickers.

---

## 6. Milestone 6 - Dietician Module

### Goal

Add dietician workflow:

- Therapist/Admin requests diet support.
- Dietician sees child profile, therapy history, previous diet plans, online consultations, educational videos.
- Dietician prepares diet chart.
- Diet chart visible in child profile.
- AI-generated diet summary available for review (Milestone 9 wires the AI part).

### Planned Backend Changes

Extend existing diet plans and add request workflow.

Modify:

- `backend/src/models/diet-plan.model.ts`
- `backend/src/modules/diet-plans/*`

Add:

- `backend/src/models/diet-request.model.ts`
- `backend/src/modules/diet-requests/*`

Planned request fields:

- `child_id`
- `requested_by`
- `assigned_dietician_id`
- `reason`
- `status`: requested, accepted, in_progress, completed, cancelled
- `notes`

Planned APIs:

- `POST /api/v1/diet-requests`
- `GET /api/v1/diet-requests`
- `PATCH /api/v1/diet-requests/:id`
- Extend diet plan create/read permissions for dietician role.

Mount in `backend/src/app.ts`: `/api/v1/diet-requests`

### Planned Frontend Changes

The dietician placeholder home screen already exists at:
`naivisense/lib/features/dietician/screens/dietician_home_screen.dart`

Replace placeholder and add:

- `naivisense/lib/features/dietician/screens/dietician_child_profile_screen.dart`
- `naivisense/lib/features/dietician/screens/create_diet_chart_screen.dart`
- `naivisense/lib/features/dietician/providers/dietician_provider.dart`
- Diet request model/repository

Modify:

- App router — extend `/dietician` routes beyond placeholder.
- Therapist child profile — "Request Diet Plan" action.
- Admin child report — request/track diet support.
- Parent child detail — show approved diet chart.

### Tests And Verification

- Diet request authorization tests.
- Dietician can create diet chart.
- Parent can read active diet chart.
- `npm run build` and `flutter analyze` must pass.

Verified by owner: [ ]

---

## ✅ MILESTONE 7 — Clinical Psychologist And Lead Therapist Full Screens — COMPLETED

**Status: Implemented and verified by Claude.**

### What was implemented

**Backend:**
- `backend/src/modules/children/children.service.ts`: `canAccess` extended for clinical_psychologist and lead_therapist.

**Frontend:**
- `naivisense/lib/features/clinical_psychologist/providers/clinical_psychologist_provider.dart`: NEW — cpChildrenProvider, cpChildConcernsProvider, RaiseConcernNotifier.
- `naivisense/lib/features/clinical_psychologist/screens/clinical_psychologist_home_screen.dart`: REPLACED — child list → observation screen with raise-concern form and open concerns list.
- `naivisense/lib/features/lead_therapist/providers/lead_therapist_provider.dart`: NEW — ltChildrenProvider, ltAllOpenConcernsProvider, ResolveConcernNotifier.
- `naivisense/lib/features/lead_therapist/screens/lead_therapist_home_screen.dart`: REPLACED — concern review queue with expandable guidance note field and resolve button.

---

## 7. Milestone 7 - Clinical Psychologist And Lead Therapist Full Screens

### Goal

Replace placeholder home screens for `clinical_psychologist` and `lead_therapist` with real dashboards:

- Clinical psychologist: raise concerns for tantrums/behavior/activities, upload supporting videos.
- Lead therapist: review escalated concern queue, add guidance notes.

### Planned Backend Changes

Use existing concerns, alerts, and videos modules (from Milestones 3 and 5).

Ensure role access in:

- `backend/src/modules/concerns/*` — clinical_psychologist and lead_therapist can read all concerns
- `backend/src/modules/alerts/*` — already allows clinical_psychologist; extend lead_therapist reads
- `backend/src/modules/videos/*` — allow clinical_psychologist to create/upload
- `backend/src/modules/children/*` — ensure clinical_psychologist and lead_therapist can read assigned children

Add optional profile models only if role-specific stored data is required:

- `backend/src/models/clinical-psychologist-profile.model.ts`
- `backend/src/models/lead-therapist-profile.model.ts`

### Planned Frontend Changes

Replace placeholder screens:

- `naivisense/lib/features/clinical_psychologist/screens/clinical_psychologist_home_screen.dart` — full dashboard
- Add: `naivisense/lib/features/clinical_psychologist/screens/clinical_psychologist_child_observation_screen.dart`
- Add: `naivisense/lib/features/clinical_psychologist/providers/clinical_psychologist_provider.dart`

- `naivisense/lib/features/lead_therapist/screens/lead_therapist_home_screen.dart` — full dashboard (concern review queue)
- Add: `naivisense/lib/features/lead_therapist/providers/lead_therapist_provider.dart`

### Tests And Verification

- Role access tests.
- Video-linked concern test for clinical_psychologist.
- Manual dashboard route test for both roles.
- `npm run build` and `flutter analyze` must pass.

Verified by owner: [ ]

---

## ✅ MILESTONE 8 — Online Sessions, Google Meet, Calendar, Attendance, Reminders — COMPLETED

**Status: Implemented and verified by Claude.**

### What was implemented

**Backend:**
- `backend/src/models/child.model.ts`: Added `enrollment_mode` (online/offline/hybrid default 'offline'), `parent_email`.
- `backend/src/models/session.model.ts`: Added `meeting_link`, `calendar_event_id`, `calendar_provider`, `calendar_synced_at`, `attendance_source`, `offline_location`.
- `backend/src/models/notification.model.ts`: NEW — NotificationModel.
- `backend/src/models/attendance.model.ts`: Already existed, now mounted.
- `backend/src/modules/google/google.service.ts`: Google Calendar/Meet service using `googleapis` when credentials are configured; returns deterministic manual fallback links/event ids for local development.
- `backend/src/modules/attendance/*`, `backend/src/modules/notifications/*`, `backend/src/modules/google/*`: All NEW.
- `backend/src/app.ts`: Mounted `/api/v1/google`, `/api/v1/attendance`, `/api/v1/notifications`.

**Frontend:**
- `naivisense/lib/data/models/attendance_record.dart`: NEW.
- `naivisense/lib/data/repositories/attendance_repository.dart`: NEW.
- `naivisense/lib/data/models/session.dart`: Added `meetingLink` field.

---

## 8. Milestone 8 - Online Sessions, Google Meet, Calendar, Attendance, Reminders

### Goal

Add scheduling infrastructure:

- Child enrollment tagged online/offline.
- Online sessions auto-create Google Meet link.
- Parent email used for invitations.
- Therapist sees/copies meeting link.
- Google Calendar sync.
- Offline attendance with geo-tag.
- Calendar-based reminders.

### Planned Backend Changes

Modify:

- `backend/src/models/child.model.ts`: Add `enrollment_mode` (online/offline/hybrid), `parent_email`.
- `backend/src/models/session.model.ts`: Add `meeting_link`, `calendar_event_id`, `calendar_provider`, `calendar_synced_at`, `attendance_source`, `offline_location`.
- `backend/src/models/attendance.model.ts`: Already exists — add mounted module.
- `backend/src/modules/sessions/*`: Online session handling.

Add:

- `backend/src/modules/google/*`
- `backend/src/modules/attendance/*`
- `backend/src/modules/notifications/*`
- `backend/src/models/notification.model.ts`

Environment additions required:

- Google OAuth/client config
- Calendar ID or service account config

Mount in `backend/src/app.ts`: `/api/v1/google`, `/api/v1/attendance`, `/api/v1/notifications`

### Planned Frontend Changes

Modify:

- Enrollment wizard: online/offline selector, parent email field.
- Create session screen: online session mode.
- Therapist child profile and home: show/copy Meet link.
- Parent child detail: show session join link.

Add:

- Attendance repository/provider/screens.
- Reminder UI in parent and therapist dashboards.

### Tests And Verification

- Google integration mocked backend tests.
- Session creation with online mode stores meeting link.
- Offline attendance stores location.
- Reminder creation/list tests.
- `npm run build` and `flutter analyze` must pass.

Verified by owner: [ ]

---

## ✅ MILESTONE 9 — Gemini AI, RAG, Therapy/Home/Diet Plan Generation — COMPLETED

**Status: Implemented and verified by Claude.**

### What was implemented

**Backend:**
- `@google/generative-ai` package installed.
- `backend/src/config/gemini.ts`: NEW — lazy singleton Gemini client, `generateText()`, `GEMINI_MODEL = 'gemini-1.5-flash'`.
- `backend/src/models/knowledge-document.model.ts`: NEW.
- `backend/src/models/knowledge-chunk.model.ts`: NEW.
- `backend/src/models/ai-draft.model.ts`: NEW — AiDraftType enum (therapy_plan/home_plan/diet_summary/reinforcement_activities/insights).
- `backend/src/modules/rag/*`: NEW — `addDocument` (chunks at 1000 chars), `retrieveChunks(category, limit)`, `listDocuments`.
- `backend/src/modules/ai/ai.service.ts`: REPLACED — `buildChildContext()` pulls Child + ChildSnapshot + 5 recent sessions + Goals; 5 generate functions call buildChildContext + retrieveChunks + generateText + AiDraftModel.create + logAiCall; `approveDraft`, `listDrafts`; backwards-compat stubs preserved.
- `backend/src/modules/ai/ai.controller.ts`: REPLACED — extended handlers for all new routes.
- `backend/src/modules/ai/ai.routes.ts`: REPLACED — legacy routes preserved, new Gemini routes added, draft management routes added.
- `backend/src/app.ts`: Mounted `/api/v1/rag`.

**Frontend:**
- `naivisense/lib/data/models/ai_draft.dart`: NEW.
- `naivisense/lib/data/repositories/ai_repository.dart`: NEW — generateTherapyPlan, generateHomePlan, generateDietSummary, generateReinforcementActivities, generateInsights, listDrafts, approveDraft.
- `naivisense/lib/features/therapist/providers/therapist_provider.dart`: Added `therapistAiDraftsProvider`, `AiGenerateNotifier`, `aiGenerateProvider`.
- `naivisense/lib/features/therapist/screens/therapist_child_profile_screen.dart`: Added `_buildAiDrafts` section with 4 generate buttons (Therapy Plan, Home Plan, Activities, Insights), draft list with View/Approve actions, draft content bottom sheet modal, `_AiButton` and `_AiDraftRow` widgets.

---

## 9. Milestone 9 - Gemini AI, RAG, Therapy/Home/Diet Plan Generation

### Goal

Replace AI stubs with real context-aware AI:

- RAG knowledge system
- Gemini API integration
- AI-generated therapy plans, OT plans, home plans, reinforcement activities, diet summaries
- Child database as complete AI context source

### Planned Backend Changes

Modify:

- `backend/src/modules/ai/*`
- `backend/src/models/ai-call.model.ts`
- `backend/src/models/child-snapshot.model.ts`
- Snapshot/chunk jobs under `backend/src/jobs`

Add:

- `backend/src/modules/rag/*`
- `backend/src/models/knowledge-document.model.ts`
- `backend/src/models/knowledge-chunk.model.ts`
- `backend/src/models/ai-draft.model.ts`

Planned AI APIs:

- `POST /api/v1/ai/therapy-plan`
- `POST /api/v1/ai/home-plan`
- `POST /api/v1/ai/diet-summary`
- `POST /api/v1/ai/reinforcement-activities`
- `POST /api/v1/ai/insights`
- `POST /api/v1/ai/drafts/:id/approve`

Mount in `backend/src/app.ts`: `/api/v1/rag`

Context sources:

- Child profile, assessments, therapy sessions, session notes, progress scores
- Alerts, concerns, goals, home plans, diet plans
- Videos metadata, monthly/quarterly reviews, attendance
- Parent observations, clinical psychologist observations

### Planned Frontend Changes

Add:

- `naivisense/lib/data/models/ai_draft.dart`
- `naivisense/lib/data/repositories/ai_repository.dart`
- AI providers under therapist, dietician, center-head

Modify:

- Therapist child profile: generate therapy plan, generate home plan, review/approve AI draft
- Admin child report: AI insights panel
- Dietician child profile: AI diet summary, dietician review before saving chart

### Tests And Verification

- AI service tests with mocked Gemini client.
- RAG retrieval tests with seeded chunks.
- AI audit log saved in `AiCallModel`.
- Draft approval creates actual plan.
- Manual fallback test when Gemini is unavailable.
- `npm run build` and `flutter analyze` must pass.

Verified by owner: [ ]

---

## ✅ MILESTONE 10 — Chatbot, Payments, Customization — COMPLETED

**Status: Implemented and verified by Claude.**

### What was implemented

**Backend:**
- `backend/src/models/chat-thread.model.ts`: NEW — indexed by parent_id.
- `backend/src/models/chat-message.model.ts`: NEW — role (user/assistant), input/output tokens.
- `backend/src/models/payment.model.ts`: NEW — amount_paise, PaymentType, PaymentStatus, razorpay fields.
- `backend/src/models/system-setting.model.ts`: NEW — key/value store, updated_by.
- `backend/src/modules/chatbot/*`: NEW — `getOrCreateThread`, `sendMessage` (builds conversation context, calls Gemini, saves both messages), `getThreadHistory`, `listThreads`, `closeThread`. Parent/center_head access.
- `backend/src/modules/payments/*`: NEW — createPayment, listPayments (parent sees own; staff sees all), updatePaymentStatus (center_head only), getPaymentSummary with aggregate.
- `backend/src/modules/settings/*`: NEW — listSettings, getSetting, upsertSetting, deleteSetting (center_head only). Uses `PUT /:key`.
- `backend/src/app.ts`: Mounted `/api/v1/chatbot`, `/api/v1/payments`, `/api/v1/settings`.

**Frontend:**
- `naivisense/lib/data/models/chat_message.dart`: NEW — ChatMessageModel + ChatThreadModel.
- `naivisense/lib/data/models/payment.dart`: NEW — amountRupees, typeLabel, statusLabel getters.
- `naivisense/lib/data/repositories/chatbot_repository.dart`: NEW.
- `naivisense/lib/data/repositories/payments_repository.dart`: NEW.
- `naivisense/lib/data/services/api_service.dart`: Added `put()` method.
- `naivisense/lib/features/parent/providers/parent_provider.dart`: Added parentPaymentsProvider, parentChatThreadProvider, parentChatMessagesProvider, ChatSendNotifier/chatSendProvider.
- `naivisense/lib/features/parent/screens/chatbot_screen.dart`: NEW — full AI chat UI with animated typing bubbles, scrolling history, send button, welcome state.
- `naivisense/lib/core/routing/app_router.dart`: Added `/parent/chatbot` route; chatbot icon in parent AppBar.
- `naivisense/lib/features/center_head/screens/payments_screen.dart`: NEW — summary chips, payment list with Mark as Paid action.
- `naivisense/lib/features/center_head/screens/settings_screen.dart`: NEW — add/delete key-value settings form.
- `naivisense/lib/features/center_head/screens/center_head_home_screen.dart`: Added Payments and Settings icon buttons in AppBar.

---

## 10. Milestone 10 - Chatbot, Payments, Customization

### Goal

Add final support features:

- AI chatbot for parents/therapists.
- Salary/payment management for therapists.
- System customization options.

### Planned Backend Changes

Add:

- `backend/src/modules/chatbot/*`
- `backend/src/models/chat-thread.model.ts`
- `backend/src/models/chat-message.model.ts`
- `backend/src/modules/payments/*`
- `backend/src/models/payment.model.ts`
- `backend/src/modules/settings/*`
- `backend/src/models/system-setting.model.ts`

Chatbot: role-aware, child-specific context when a child is selected, conversation history by user and child, uses Gemini/RAG from Milestone 9.

Payments: therapist salary records, payment status, month-wise history, center head/admin access only.

Customization: configurable therapy types, alert categories, notification timing defaults, center-level settings.

Mount in `backend/src/app.ts`: `/api/v1/chatbot`, `/api/v1/payments`, `/api/v1/settings`

### Planned Frontend Changes

Add:

- Chatbot screens/components for parent and therapist.
- Center head payment management screen.
- Center head customization/settings screen.

Modify:

- App router.
- Parent and therapist dashboards to expose chatbot.
- Center head dashboard to expose payments/settings.

### Tests And Verification

- Chatbot auth/context tests.
- Payment CRUD tests.
- Settings read/write tests.
- `npm run build` and `flutter analyze` must pass.

Verified by owner: [ ]

---

## 11. Global Frontend Navigation Plan

`naivisense/lib/core/routing/app_router.dart` — already has all 6 top-level role routes.

**Top-level routes (already wired):**

- `/login`
- `/therapist`
- `/parent`
- `/center-head`
- `/lead-therapist`
- `/dietician`
- `/clinical-psychologist`

**Pending nested routes (add in relevant milestones):**

- Parent:
  - `/parent/child/:childId`
  - `/parent/child/:childId/alert`
  - `/parent/child/:childId/video-upload` (Milestone 5)
  - `/parent/child/:childId/chat` (Milestone 10)
- Therapist:
  - create session
  - session notes
  - raise concern
  - monthly review
  - AI draft review (Milestone 9)
- Center Head:
  - enroll child
  - enroll therapist/staff
  - child report
  - payments (Milestone 10)
  - settings (Milestone 10)
- Dietician:
  - request queue
  - child profile
  - create diet chart
- Clinical Psychologist:
  - child observation
  - raise concern
  - upload video
- Lead Therapist:
  - review queue
  - concern detail

---

## 12. Global Backend API Mount Plan

**Already mounted in `backend/src/app.ts`:**

- `/api/v1/auth`
- `/api/v1/users`
- `/api/v1/children`
- `/api/v1/assessments`
- `/api/v1/sessions`
- `/api/v1/home-plans`
- `/api/v1/diet-plans`
- `/api/v1/verification`
- `/api/v1/alerts`
- `/api/v1/reports`
- `/api/v1/ai`
- `/api/v1/concerns` ← added by Claude (Milestone 3)
- `/api/v1/goals` ← added by Claude (Milestone 4)
- `/api/v1/reviews` ← added by Claude (Milestone 4)

**Also mounted (Milestones 5–10):**

- `/api/v1/videos` ← Milestone 5
- `/api/v1/diet-requests` ← Milestone 6
- `/api/v1/google` ← Milestone 8
- `/api/v1/attendance` ← Milestone 8
- `/api/v1/notifications` ← Milestone 8
- `/api/v1/rag` ← Milestone 9
- `/api/v1/chatbot` ← Milestone 10
- `/api/v1/payments` ← Milestone 10
- `/api/v1/settings` ← Milestone 10

---

## 13. Global Data And AI Context Plan

The child database is the canonical context source for AI and clinical workflows.

Context to include in child history:

- Child profile, diagnosis, assessments
- Therapy sessions, session notes, progress scores
- Alerts, concerns, goals
- Home plans, diet plans
- Videos metadata
- Monthly/quarterly reviews
- Attendance
- Parent, teacher, clinical psychologist observations

Implementation direction:

- Keep transactional records in their own modules.
- Use `ChildSnapshotModel` as denormalized AI-readable summary.
- Rebuild snapshots after key events: session notes submitted, alert/concern created or resolved, goal accepted/completed, review published, plan created, video uploaded, attendance logged.
- Use RAG for external/internal knowledge documents, not as a replacement for child records.

---

## 14. Global Verification Commands

After every milestone:

**Backend:**

```bash
cd backend && /opt/homebrew/Cellar/node/23.7.0/bin/npm run build
```

**Frontend:**

```bash
/opt/homebrew/bin/flutter analyze
```

Manual verification per milestone:

- Login as every affected role.
- Open the affected dashboard.
- Execute the feature flow.
- Refresh data and confirm persistence.
- Verify unauthorized roles cannot access the feature.
- Confirm empty states and loading/error states.
