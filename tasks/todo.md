# NaiviSense Feature Execution — Milestone 4: Goals, Progress Logs, Monthly & Quarterly Reviews

**Objective:** Add GoalModel + ReviewModel with full CRUD APIs; surface goals in therapist profile, parent view (read-only accepted goals), and admin report; add monthly/quarterly review creation and timeline.

## Backend Steps

- [ ] `goal.model.ts` — child_id, created_by, title, description, priority, status, accepted_by, accepted_at, target_date
- [ ] `goals/*` — schema, service, controller, routes (POST/GET/PATCH)
- [ ] `review.model.ts` — child_id, review_type, created_by, period_start, period_end, text_observations, admin_notes, video_ids, assessment_id, status
- [ ] `reviews/*` — schema, service, controller, routes (POST/GET/PATCH)
- [ ] Mount /api/v1/goals and /api/v1/reviews in app.ts

## Flutter Steps

- [ ] `goal.dart` — GoalModel
- [ ] `review.dart` — ReviewModel
- [ ] `goals_repository.dart`
- [ ] `reviews_repository.dart`
- [ ] therapist_provider.dart — goalsProvider, reviewsProvider
- [ ] therapist_child_profile_screen.dart — Goals section + Monthly Review action
- [ ] admin_child_report_screen.dart — Reviews timeline + admin notes
- [ ] child_detail_screen.dart (parent) — read-only accepted goals + published reviews

## Verification

- [ ] `cd backend && npm run build`
- [ ] `cd naivisense && flutter analyze`
