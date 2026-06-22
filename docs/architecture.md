# NaiviSense — Doc 1: Architecture & System Design
> **Single source of truth** for system map, roles, data flow, tech stack,
> security model, and database schema. Every other doc derives from this one.
> Where any other doc disagrees, this file wins.

---

## 1. Product Mission

> Help therapists treat better, parents participate better, and children
> improve consistently — by replacing WhatsApp-and-paper therapy coordination
> with a structured, data-driven, AI-assisted platform.

### 1.1 The Real Problem (Concrete)

| Problem | Evidence |
|---------|----------|
| **Fragmented communication** | Updates live in WhatsApp threads + paper notebooks |
| **No measurable progress** | "Improving" is a feeling, not a number |
| **Low parent involvement** | Home practice is the #1 predictor of outcomes — zero structure |
| **No continuity of care** | When a therapist is unavailable, the next one starts from zero |
| **No learning loop** | Outcomes never feed back into how plans are made |

### 1.2 The Solution

A multi-role app where:
- **Therapists plan** (AI-assisted, therapist-edited)
- **Parents execute** (tasks, proof photos, daily feedback)
- **The system verifies** (center head approves proof)
- **An AI layer learns** (outcomes → better plans → outcomes)

---

## 2. Three Roles, Three Jobs

| Role | Primary Job | Key Screen |
|------|------------|------------|
| **Center Head / Admin** | Onboard children, assign therapists, verify parent proof photos, analytics | Verification panel + child overview |
| **Therapist** | Assess child, create AI-assisted plans, run sessions, track progress | AI plan editor + session notes + progress dashboard |
| **Parent** | Execute today's tasks, photo proof, emoji feedback | Today timeline + camera + daily feedback |

> **V1 note:** Center Head and Admin are the same role. Multi-center
> super-admin is a V2 concern.

---

## 3. System Architecture

### 3.1 Logical Layers

```
┌─────────────────────────────────────────────────────────────┐
│                  CLIENTS (Flutter — one codebase)           │
│      Parent app  ·  Therapist app  ·  Center Head app       │
└─────────────────────────────┬───────────────────────────────┘
                              │  HTTPS / JWT
┌─────────────────────────────▼───────────────────────────────┐
│              Node.js API — Express 4.x + TypeScript         │
│    Rate limit · Auth middleware · Role guard · Ownership    │
└──────┬──────────────────────────────────────┬───────────────┘
       │                                      │
┌──────▼──────┐                    ┌──────────▼──────────────┐
│  MongoDB    │                    │  AI Service (Python)    │
│  Atlas M10  │◄──────────────────┤  FastAPI + Claude SDK   │
│  (Mumbai)   │  read/write       │  + Voyage AI embeddings │
│             │                    └─────────────────────────┘
│  + Vector   │
│    Search   │     ┌─────────────────────────┐
└─────────────┘     │  S3  ap-south-1        │
                    │  (photos + PDFs)        │
                    └─────────────────────────┘
                              ▲
                    ┌─────────┴──────────┐
                    │  BullMQ + Redis    │
                    │  (background jobs) │
                    └────────────────────┘
```

### 3.2 Data Flow — Core Loop

```
[Therapist] generates plan (AI-assisted)
      │
      ▼ edits + approves
[Backend] stores home_plan + logs diff as RAG chunk
      │
      ▼ pushes tasks to parent
[Parent] executes task + takes photo proof
      │
      ▼ uploads via camera screen
[Backend] creates home_task_log (pending)
      │
      ▼ queued for review
[Center Head] approves / rejects proof in verification panel
      │
      ▼ signals feed back
[BullMQ] rebuilds child_snapshot + embeds new chunk
      │
      ▼ next time therapist requests a plan
[AI Service] retrieves relevant chunks → better suggestions
```

---

## 4. Tech Stack (Locked)

### 4.1 Flutter App

| Concern | Package | Version |
|---------|---------|---------|
| State management | flutter_riverpod | ^2.5.1 |
| Navigation | go_router | ^13.2.4 |
| HTTP client | dio | ^5.4.3 |
| Secure token storage | flutter_secure_storage | ^9.0.0 |
| Charts | fl_chart | ^0.68.0 |
| Camera | image_picker | ^1.1.2 |
| Offline cache | hive_flutter | ^1.1.0 |
| Animations | lottie | ^3.1.2 |
| Connectivity | connectivity_plus | ^6.0.3 |
| Fonts | Inter (Google Fonts) | — |

### 4.2 Node.js Backend

| Concern | Tech | Version |
|---------|------|---------|
| Runtime | Node.js | 20 LTS |
| Framework | Express | 4.x |
| Language | TypeScript | 5.4+ |
| Database ODM | Mongoose | 8.x |
| Auth | jsonwebtoken + bcrypt | 9 + 5 |
| Validation | Zod | 3.x |
| File upload | Multer | 1.x |
| Object storage | aws-sdk v3 (S3 ap-south-1) | — |
| Queue | BullMQ + Redis | 5.x + 7.x |
| Logger | Pino | 8.x |
| API docs | zod-to-openapi (OpenAPI 3.1) | — |
| Tests | Vitest + Supertest | — |

### 4.3 AI Service (Python)

| Concern | Tech | Version |
|---------|------|---------|
| Runtime | Python | 3.11 |
| Framework | FastAPI | 0.110+ |
| LLM | Anthropic Claude SDK | latest |
| Embeddings | Voyage AI (voyage-3) | latest |
| Vector DB | MongoDB Atlas Vector Search | — |
| Validation | Pydantic | 2.x |

---

## 5. Complete Database Schemas

### 5.1 users

```js
{
  _id:           ObjectId,
  role:          'center_head' | 'therapist' | 'parent',
  phone:         String,           // E.164, unique, indexed
  email:         String?,          // unique sparse
  password_hash: String,           // bcrypt cost ≥ 12
  name:          String,
  photo_url:     String?,          // S3 URL
  is_verified:   Boolean,          // default false; V2 = OTP verified
  created_at:    Date,
  updated_at:    Date
}
// Indexes: phone (unique), email (sparse unique)
```

### 5.2 therapist_profiles (1:1 with users)

```js
{
  _id:                ObjectId,
  user_id:            ObjectId,         // ref users
  qualification:      String,
  certifications:     [String],
  years_experience:   Number,
  workplace_type:     'clinic'|'hospital'|'freelance'|'ngo',
  organization_name:  String?,
  license_number:     String?,
  age_groups:         [String],         // ['0-3','3-6','6-12','teens']
  conditions_handled: [String],         // ['autism','adhd','down_syndrome',...]
  therapy_methods:    [String],         // ['aba','play_therapy','sensory_integration',...]
  available_days:     [String],         // ['mon','tue','wed',...]
  session_modes:      [String],         // ['online','offline']
  session_duration:   Number,           // minutes
}
```

### 5.3 children (core entity)

```js
{
  _id:              ObjectId,
  name:             String,
  nickname:         String?,
  dob:              Date,
  gender:           'boy'|'girl'|'other',
  photo_url:        String?,
  diagnosis:        [String],           // ['autism','adhd','speech_delay',...]
  severity:         'mild'|'moderate'|'high_support',
  primary_concerns: [String],
  therapy_targets:  [String],           // ['speech','ot','social_skills',...]
  therapist_id:     ObjectId?,          // ref users
  parent_id:        ObjectId,           // ref users (required)
  center_id:        ObjectId?,          // V2: ref organisations
  medical: {
    birth_history:  'normal'|'premature'|'complications',
    milestones_delay: Boolean,
    hearing_issues: Boolean,
    vision_issues:  Boolean,
    current_medications: [String]
  },
  emergency_contact: { name: String, phone: String },
  documents: [{
    url: String, type: String, uploaded_at: Date
  }],
  home_context: {                       // The Sangat Layer
    primary_caregiver:   String,
    screen_time_hours:   Number,
    play_type:           'alone'|'guided'|'group',
    parent_involvement:  'low'|'medium'|'high'
  },
  goals: {
    priorities:       [String],
    timeline_months:  Number
  },
  consent_record: { given_at: Date, given_by: String },
  created_at:     Date,
  updated_at:     Date
}
// Indexes: parent_id, therapist_id, (center_id, created_at)
```

### 5.4 child_snapshots (AI source of truth)

```js
{
  _id:        ObjectId,
  child_id:   ObjectId,               // ref children
  is_current: Boolean,                // exactly ONE true per child
  version:    Number,
  updated_at: Date,
  profile: {
    age: Number, diagnosis: [String],
    notes: String, home_context: Object
  },
  baseline_assessment: {
    date: Date,
    traits: { eye_contact:1-5, grip:1-5, behavior:1-5, walking:1-5,
              communication:1-5, motor_skills:1-5, attention:1-5 }
  },
  latest_assessment: { date, traits, summary: String },
  trends: { eye_contact: 'improving'|'stable'|'regressing', ... },
  compliance: { home_plan_pct: Number, diet_plan_pct: Number, attendance_pct: Number },
  recent_issues: [String],
  recent_wins:   [String],
  ai_insights: {
    progress_level:  'mild'|'moderate'|'significant'|'concerning',
    risk_flags:      [String],
    strengths:       [String],
    recommendations: [String]
  },
  next_goals: [String]
}
// Index: (child_id, is_current) unique partial
```

### 5.5 rag_chunks (Vector search)

```js
{
  _id:        ObjectId,
  child_id:   ObjectId,               // ALWAYS filter by this first
  type:       'assessment_summary'|'session_summary'|'plan_outcome'|
              'therapist_correction'|'verification_outcome',
  content:    String,                 // 200-500 tokens
  embedding:  [Number],              // 1024-dim voyage-3 vector
  source_ref: ObjectId,              // original record
  signals: {
    compliance: Number?,             // 0.0–1.0
    approved:   Boolean?             // verification result
  },
  created_at: Date
}
// Atlas Vector Search index on embedding, filter field: child_id
```

### 5.6 assessments

```js
{
  _id:        ObjectId,
  child_id:   ObjectId,
  type:       'initial'|'reassessment'|'parent_feedback',
  date:       Date,
  traits: {
    eye_contact:    Number,  // 1-5
    grip:           Number,
    behavior:       Number,
    walking:        Number,
    communication:  Number,
    motor_skills:   Number,
    attention:      Number
  },
  notes:      String,
  created_by: ObjectId     // ref users
}
```

### 5.7 sessions + session_notes

```js
// sessions
{
  _id:          ObjectId,
  child_id:     ObjectId,
  therapist_id: ObjectId,
  scheduled_at: Date,
  status:       'scheduled'|'completed'|'cancelled',
  mode:         'online'|'offline',
  duration_min: Number,
  type:         'speech'|'ot'|'behavior'|'special_ed',
  notes_id:     ObjectId?  // ref session_notes
}

// session_notes
{
  _id:          ObjectId,
  session_id:   ObjectId,
  child_id:     ObjectId,
  therapist_id: ObjectId,
  mood:         'sad'|'calm'|'happy'|'excited',
  ratings: {
    attention:     Number,  // 1-10
    communication: Number,
    motor_skills:  Number,
    behavior:      Number
  },
  activities:   [String],
  notes:        String,
  submitted_at: Date
}
```

### 5.8 home_plans + home_task_logs

```js
// home_plans
{
  _id:          ObjectId,
  child_id:     ObjectId,
  therapist_id: ObjectId,
  start_date:   Date,
  end_date:     Date,
  tasks: [{
    task_id:      String,
    title:        String,
    description:  String,
    icon:         String,             // emoji
    time_of_day:  'morning'|'afternoon'|'evening',
    duration_min: Number,
    frequency:    'daily'|'weekly',
    target_count: Number
  }],
  ai_draft_diff: Object?,             // what therapist changed from AI suggestion
  created_at:   Date
}

// home_task_logs
{
  _id:             ObjectId,
  home_plan_id:    ObjectId,
  task_id:         String,
  child_id:        ObjectId,
  logged_by:       ObjectId,         // parent
  logged_at:       Date,
  image_url:       String,           // S3
  status:          'pending'|'approved'|'rejected',
  verification_id: ObjectId?
}
```

### 5.9 verification

```js
{
  _id:         ObjectId,
  log_id:      ObjectId,              // ref home_task_logs or meal_logs
  log_type:    'home'|'diet'|'attendance',
  verified_by: ObjectId,              // center_head
  status:      'approved'|'rejected',
  remarks:     String?,
  verified_at: Date
}
```

### 5.10 alerts

```js
{
  _id:             ObjectId,
  child_id:        ObjectId,
  raised_by:       ObjectId,          // parent
  type:            'fever'|'regression'|'aggression'|'seizure'|
                   'sleep_issue'|'injury'|'emotional_stress'|'other',
  description:     String,
  severity:        'low'|'medium'|'high',
  status:          'open'|'seen'|'resolved',
  created_at:      Date,
  acknowledged_at: Date?,
  resolved_at:     Date?
}
```

### 5.11 ai_calls (mandatory audit — every AI call)

```js
{
  _id:              ObjectId,
  called_by:        ObjectId,
  child_id:         ObjectId,
  endpoint:         '/ai/plan'|'/ai/insights'|'/ai/report',
  model:            String,           // 'claude-sonnet-4-6' etc.
  input_tokens:     Number,
  output_tokens:    Number,
  latency_ms:       Number,
  prompt_id:        String,           // hash of prompt template version
  redacted_request: Object,           // PII stripped
  response_summary: String,
  cost_usd:         Number,
  created_at:       Date
}
```

---

## 6. API Endpoint Index

### Auth
```
POST   /api/v1/auth/register
POST   /api/v1/auth/login
POST   /api/v1/auth/refresh
POST   /api/v1/auth/logout
```

### Users
```
GET    /api/v1/users/me
PATCH  /api/v1/users/me
POST   /api/v1/users/me/photo       multipart
```

### Children
```
POST   /api/v1/children             center_head
GET    /api/v1/children             scoped by role
GET    /api/v1/children/:id
PATCH  /api/v1/children/:id
GET    /api/v1/children/:id/snapshot
```

### Assessments
```
POST   /api/v1/assessments
GET    /api/v1/assessments?childId=
GET    /api/v1/assessments/:id
```

### Sessions
```
POST   /api/v1/sessions             therapist
POST   /api/v1/sessions/:id/notes
GET    /api/v1/sessions/upcoming
GET    /api/v1/sessions?childId=
```

### Home Plans
```
POST   /api/v1/home-plans           therapist
GET    /api/v1/home-plans/active?childId=
POST   /api/v1/home-plans/:id/tasks/:taskId/log   parent, multipart
```

### Diet Plans
```
POST   /api/v1/diet-plans           therapist
GET    /api/v1/diet-plans/active?childId=
POST   /api/v1/diet-plans/:id/meals/:mealId/log   parent
```

### Verification
```
GET    /api/v1/verification/pending  center_head
POST   /api/v1/verification/:logId   approve|reject
```

### Reports
```
GET    /api/v1/reports/progress?childId=&from=&to=
GET    /api/v1/reports/monthly?childId=&month=
GET    /api/v1/reports/monthly/:id/pdf
```

### Alerts
```
POST   /api/v1/alerts               parent
GET    /api/v1/alerts?childId=
PATCH  /api/v1/alerts/:id
```

### AI Orchestration
```
POST   /api/v1/ai/plan              therapist
POST   /api/v1/ai/plan/:draftId/approve
POST   /api/v1/ai/insights
```

---

## 7. Security Model

```
Rule                          Detail
──────────────────────────────────────────────────────────────
HTTPS only                    TLS terminated at ALB / Cloudflare
Helmet middleware             Removes fingerprinting headers
CORS                          Allowlist Flutter app origin only — NOT *
Rate limiting                 100 req/min per IP; 10 login attempts/15min per phone
Bcrypt cost                   ≥ 12 rounds
JWT rotation                  Access 15min; Refresh 7d; secrets rotated quarterly
S3 access                     All buckets private; presigned URLs (15-min expiry)
PII in logs                   Pino redact: password_hash, phone in payloads
Audit log                     Every read/write of child data
AI prompt injection           USER_INPUT wrapped in <USER_INPUT> fence; treated as data
Consent                       Child creation blocked without consent_record
Auto-approve AI               Blocked server-side; therapist sign-off is mandatory
Data residency                MongoDB Atlas Mumbai, S3 ap-south-1, ECS Mumbai
DPDP Act                      consent_record stored on every child document
```

---

## 8. Deployment Architecture

| Component | Where | Spec |
|-----------|-------|------|
| Node API | AWS ECS Fargate, 2 tasks, ALB | ap-south-1 |
| AI service | AWS ECS Fargate, 1 task, same VPC | ap-south-1 |
| MongoDB | Atlas M10 Mumbai | Replica set |
| Redis | Elasticache cache.t4g.small | — |
| S3 | ap-south-1 | 6mo → IA, 1yr → Glacier |
| CDN | CloudFront (image delivery only) | — |
| CI/CD | GitHub Actions → ECR → ECS | — |
| Secrets | AWS Secrets Manager | No env vars in ECS task def |
| Monitoring | Sentry + CloudWatch | — |

---

## 9. Revenue Model

| Tier | Price | Target |
|------|-------|--------|
| Therapist Solo SaaS | ₹999–₹2999/month | Individual practitioners |
| Clinic B2B | Custom / per-child | Therapy centers |
| Parent Premium | ₹299/month | Advanced AI reports, coach |
| Enterprise | Custom | Hospital chains, NGOs, schools |

---

## 10. What's Done vs What's Not

```
✅  Flutter UI shell (~28 files)          All 10 screens from design reference
✅  Design system locked                  Colors, typography, components
✅  GoRouter + Riverpod wired             Basic routing and state
✅  Mock data layer                       mock_repository.dart
❌  Backend (Node.js)                     Not started
❌  Real auth                             Mock login only
❌  Camera proof / verification           New requirement — not in Flutter yet
❌  AI / RAG layer                        Not started
```

Overall: **~28% toward MVP** (UI shell only, no backend, no persistence).

---

*Last revised: May 2026. This document is the canonical source of truth.*
