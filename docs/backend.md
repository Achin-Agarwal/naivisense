# NaiviSense — Doc 3: Backend (Node.js) Implementation
> Complete Node.js/Express/TypeScript codebase guide with sample code.
> Read Doc 1 (Architecture) first for schemas and API index.

---

## 1. Project Setup

### 1.1 package.json

```json
{
  "name": "naivisense-api",
  "version": "1.0.0",
  "scripts": {
    "dev":        "tsx watch src/index.ts",
    "build":      "tsc --outDir dist",
    "start":      "node dist/index.js",
    "test":       "vitest run",
    "test:watch": "vitest"
  },
  "dependencies": {
    "express":             "^4.19.2",
    "mongoose":            "^8.3.4",
    "bcrypt":              "^5.1.1",
    "jsonwebtoken":        "^9.0.2",
    "zod":                 "^3.23.8",
    "multer":              "^1.4.5-lts.1",
    "@aws-sdk/client-s3":  "^3.573.0",
    "@aws-sdk/s3-request-presigner": "^3.573.0",
    "bullmq":              "^5.8.0",
    "ioredis":             "^5.3.2",
    "pino":                "^9.1.0",
    "pino-pretty":         "^11.0.0",
    "helmet":              "^7.1.0",
    "cors":                "^2.8.5",
    "express-rate-limit":  "^7.3.1",
    "dotenv":              "^16.4.5"
  },
  "devDependencies": {
    "typescript":          "^5.4.5",
    "tsx":                 "^4.10.5",
    "@types/express":      "^4.17.21",
    "@types/bcrypt":       "^5.0.2",
    "@types/jsonwebtoken": "^9.0.6",
    "@types/multer":       "^1.4.11",
    "@types/cors":         "^2.8.17",
    "vitest":              "^1.6.0",
    "supertest":           "^7.0.0",
    "@types/supertest":    "^6.0.2",
    "mongodb-memory-server": "^9.2.0"
  }
}
```

### 1.2 tsconfig.json

```json
{
  "compilerOptions": {
    "target":           "ES2022",
    "module":           "CommonJS",
    "lib":              ["ES2022"],
    "outDir":           "dist",
    "rootDir":          "src",
    "strict":           true,
    "esModuleInterop":  true,
    "resolveJsonModule": true,
    "skipLibCheck":     true
  },
  "include": ["src/**/*"],
  "exclude": ["node_modules", "dist", "tests"]
}
```

### 1.3 .env.example

```
NODE_ENV=development
PORT=8000

MONGO_URL=mongodb://localhost:27017/naivisense
REDIS_URL=redis://localhost:6379

JWT_ACCESS_SECRET=replace-with-openssl-rand-hex-32
JWT_REFRESH_SECRET=replace-with-another-openssl-rand-hex-32
ACCESS_TOKEN_EXPIRES=15m
REFRESH_TOKEN_EXPIRES=7d

S3_BUCKET=naivisense-dev
S3_REGION=ap-south-1
AWS_ACCESS_KEY_ID=
AWS_SECRET_ACCESS_KEY=

AI_SERVICE_URL=http://localhost:8001
AI_SERVICE_TOKEN=shared-secret-between-node-and-python

ALLOWED_ORIGIN=http://localhost:3000
```

### 1.4 docker-compose.yml (local dev)

```yaml
version: '3.9'
services:
  mongo:
    image: mongo:7
    ports: ["27017:27017"]
    volumes: [mongo_data:/data/db]
  redis:
    image: redis:7-alpine
    ports: ["6379:6379"]
volumes:
  mongo_data:
```

### 1.5 Complete File Structure

```
backend/
├── package.json
├── tsconfig.json
├── .env.example
├── docker-compose.yml
│
├── src/
│   ├── index.ts
│   ├── app.ts
│   │
│   ├── config/
│   │   ├── env.ts
│   │   ├── db.ts
│   │   ├── redis.ts
│   │   └── s3.ts
│   │
│   ├── middleware/
│   │   ├── auth.ts
│   │   ├── role.ts
│   │   ├── error.ts
│   │   ├── rate-limit.ts
│   │   └── upload.ts
│   │
│   ├── models/
│   │   ├── user.model.ts
│   │   ├── therapist-profile.model.ts
│   │   ├── child.model.ts
│   │   ├── child-snapshot.model.ts
│   │   ├── assessment.model.ts
│   │   ├── session.model.ts
│   │   ├── session-notes.model.ts
│   │   ├── home-plan.model.ts
│   │   ├── home-task-log.model.ts
│   │   ├── diet-plan.model.ts
│   │   ├── attendance.model.ts
│   │   ├── verification.model.ts
│   │   ├── alert.model.ts
│   │   └── ai-call.model.ts
│   │
│   ├── modules/
│   │   ├── auth/
│   │   │   ├── auth.routes.ts
│   │   │   ├── auth.controller.ts
│   │   │   ├── auth.service.ts
│   │   │   └── auth.schema.ts
│   │   ├── users/
│   │   │   ├── users.routes.ts
│   │   │   ├── users.controller.ts
│   │   │   └── users.service.ts
│   │   ├── children/
│   │   │   ├── children.routes.ts
│   │   │   ├── children.controller.ts
│   │   │   ├── children.service.ts
│   │   │   └── children.schema.ts
│   │   ├── assessments/
│   │   ├── sessions/
│   │   ├── home-plans/
│   │   ├── diet-plans/
│   │   ├── verification/
│   │   ├── alerts/
│   │   ├── reports/
│   │   └── ai/
│   │
│   ├── jobs/
│   │   ├── queues.ts
│   │   ├── snapshot.job.ts
│   │   ├── chunk.job.ts
│   │   └── report.job.ts
│   │
│   └── utils/
│       ├── http.ts
│       └── logger.ts
│
└── tests/
    ├── setup.ts
    ├── auth.test.ts
    └── children.test.ts
```

---

## 2. Application Entry Points

### 2.1 src/index.ts

```typescript
import 'dotenv/config';
import { connectDB }   from './config/db';
import { connectRedis } from './config/redis';
import logger           from './utils/logger';
import app              from './app';

const PORT = process.env.PORT ?? 8000;

async function main() {
  try {
    await connectDB();
    await connectRedis();
    app.listen(PORT, () => {
      logger.info({ port: PORT }, 'NaiviSense API started');
    });
  } catch (err) {
    logger.error(err, 'Failed to start server');
    process.exit(1);
  }
}

main();
```

### 2.2 src/app.ts

```typescript
import express              from 'express';
import helmet               from 'helmet';
import cors                 from 'cors';
import { generalRateLimit } from './middleware/rate-limit';
import { errorHandler }     from './middleware/error';
import authRoutes           from './modules/auth/auth.routes';
import usersRoutes          from './modules/users/users.routes';
import childrenRoutes       from './modules/children/children.routes';
import assessmentsRoutes    from './modules/assessments/assessments.routes';
import sessionsRoutes       from './modules/sessions/sessions.routes';
import homePlansRoutes      from './modules/home-plans/home-plans.routes';
import dietPlansRoutes      from './modules/diet-plans/diet-plans.routes';
import verificationRoutes   from './modules/verification/verification.routes';
import alertsRoutes         from './modules/alerts/alerts.routes';
import reportsRoutes        from './modules/reports/reports.routes';
import aiRoutes             from './modules/ai/ai.routes';

const app = express();

// ── Security ────────────────────────────────────────────────────
app.use(helmet());
app.use(cors({ origin: process.env.ALLOWED_ORIGIN ?? '*', credentials: true }));
app.use(generalRateLimit);

// ── Body parsing ────────────────────────────────────────────────
app.use(express.json({ limit: '10mb' }));
app.use(express.urlencoded({ extended: true }));

// ── Health check ────────────────────────────────────────────────
app.get('/health', (_, res) => res.json({ status: 'ok', ts: Date.now() }));

// ── API routes ──────────────────────────────────────────────────
const api = '/api/v1';
app.use(`${api}/auth`,         authRoutes);
app.use(`${api}/users`,        usersRoutes);
app.use(`${api}/children`,     childrenRoutes);
app.use(`${api}/assessments`,  assessmentsRoutes);
app.use(`${api}/sessions`,     sessionsRoutes);
app.use(`${api}/home-plans`,   homePlansRoutes);
app.use(`${api}/diet-plans`,   dietPlansRoutes);
app.use(`${api}/verification`, verificationRoutes);
app.use(`${api}/alerts`,       alertsRoutes);
app.use(`${api}/reports`,      reportsRoutes);
app.use(`${api}/ai`,           aiRoutes);

// ── Central error handler (must be last) ────────────────────────
app.use(errorHandler);

export default app;
```

---

## 3. Config

### 3.1 config/env.ts

```typescript
import { z } from 'zod';

const envSchema = z.object({
  NODE_ENV:              z.enum(['development', 'production', 'test']).default('development'),
  PORT:                  z.coerce.number().default(8000),
  MONGO_URL:             z.string().url(),
  REDIS_URL:             z.string().url(),
  JWT_ACCESS_SECRET:     z.string().min(32),
  JWT_REFRESH_SECRET:    z.string().min(32),
  ACCESS_TOKEN_EXPIRES:  z.string().default('15m'),
  REFRESH_TOKEN_EXPIRES: z.string().default('7d'),
  S3_BUCKET:             z.string(),
  S3_REGION:             z.string().default('ap-south-1'),
  AWS_ACCESS_KEY_ID:     z.string(),
  AWS_SECRET_ACCESS_KEY: z.string(),
  AI_SERVICE_URL:        z.string().url(),
  AI_SERVICE_TOKEN:      z.string().min(16),
  ALLOWED_ORIGIN:        z.string().default('*'),
});

const parsed = envSchema.safeParse(process.env);
if (!parsed.success) {
  console.error('❌ Invalid environment variables:', parsed.error.format());
  process.exit(1);
}

export const env = parsed.data;
```

### 3.2 config/db.ts

```typescript
import mongoose from 'mongoose';
import { env }  from './env';
import logger   from '../utils/logger';

export async function connectDB(): Promise<void> {
  mongoose.set('strictQuery', true);
  await mongoose.connect(env.MONGO_URL, { serverSelectionTimeoutMS: 5000 });
  logger.info('MongoDB connected');
}
```

### 3.3 config/s3.ts

```typescript
import { S3Client, PutObjectCommand } from '@aws-sdk/client-s3';
import { getSignedUrl }               from '@aws-sdk/s3-request-presigner';
import { env }                        from './env';

export const s3 = new S3Client({
  region:      env.S3_REGION,
  credentials: {
    accessKeyId:     env.AWS_ACCESS_KEY_ID,
    secretAccessKey: env.AWS_SECRET_ACCESS_KEY,
  },
});

/** Generate a presigned PUT URL (15 min expiry) for client direct-upload */
export async function presignUpload(key: string, contentType: string): Promise<string> {
  const cmd = new PutObjectCommand({
    Bucket:      env.S3_BUCKET,
    Key:         key,
    ContentType: contentType,
  });
  return getSignedUrl(s3, cmd, { expiresIn: 900 });
}

export function s3Url(key: string): string {
  return `https://${env.S3_BUCKET}.s3.${env.S3_REGION}.amazonaws.com/${key}`;
}
```

---

## 4. Middleware

### 4.1 middleware/auth.ts

```typescript
import { Request, Response, NextFunction } from 'express';
import jwt                                  from 'jsonwebtoken';
import { env }                              from '../config/env';

export interface AuthPayload {
  sub:  string;
  role: 'center_head' | 'therapist' | 'parent';
  iat:  number;
  exp:  number;
}

declare global {
  namespace Express {
    interface Request { user?: AuthPayload }
  }
}

export function requireAuth(req: Request, res: Response, next: NextFunction): void {
  const header = req.headers.authorization;
  if (!header?.startsWith('Bearer ')) {
    res.status(401).json(apiError('UNAUTHORIZED', 'Authentication required'));
    return;
  }
  try {
    req.user = jwt.verify(header.slice(7), env.JWT_ACCESS_SECRET) as AuthPayload;
    next();
  } catch {
    res.status(401).json(apiError('UNAUTHORIZED', 'Token expired or invalid'));
  }
}

// Helper reused in error middleware
export function apiError(code: string, message: string, details?: unknown) {
  return {
    error: { code, message, details, retryable: false, request_id: undefined },
  };
}
```

### 4.2 middleware/role.ts

```typescript
import { Request, Response, NextFunction } from 'express';
import { apiError }                         from './auth';

type Role = 'center_head' | 'therapist' | 'parent';

export function requireRole(...roles: Role[]) {
  return (req: Request, res: Response, next: NextFunction): void => {
    if (!req.user || !roles.includes(req.user.role as Role)) {
      res.status(403).json(apiError('FORBIDDEN', 'Insufficient permissions'));
      return;
    }
    next();
  };
}
```

### 4.3 middleware/error.ts

```typescript
import { Request, Response, NextFunction } from 'express';
import { ZodError }                         from 'zod';
import logger                               from '../utils/logger';

const STATUS_MAP: Record<string, number> = {
  CONFLICT:      409,
  UNAUTHORIZED:  401,
  FORBIDDEN:     403,
  NOT_FOUND:     404,
  INVALID_INPUT: 400,
  RATE_LIMITED:  429,
};

export class AppError extends Error {
  constructor(public code: string, message: string, public details?: unknown) {
    super(message);
    this.name = 'AppError';
  }
}

export function errorHandler(
  err: unknown,
  req: Request,
  res: Response,
  _next: NextFunction,
): void {
  if (err instanceof ZodError) {
    res.status(400).json({
      error: {
        code:      'INVALID_INPUT',
        message:   'Validation failed',
        details:   err.flatten().fieldErrors,
        retryable: false,
      },
    });
    return;
  }

  if (err instanceof AppError) {
    const status = STATUS_MAP[err.code] ?? 400;
    res.status(status).json({
      error: { code: err.code, message: err.message, details: err.details, retryable: false },
    });
    return;
  }

  logger.error(err, 'Unhandled error');
  res.status(500).json({
    error: { code: 'SERVER_ERROR', message: 'Internal server error', retryable: true },
  });
}
```

### 4.4 middleware/rate-limit.ts

```typescript
import rateLimit from 'express-rate-limit';

export const generalRateLimit = rateLimit({
  windowMs: 60 * 1000,  // 1 minute
  max: 100,
  standardHeaders: true,
  legacyHeaders:   false,
  message: { error: { code: 'RATE_LIMITED', message: 'Too many requests', retryable: true } },
});

export const authRateLimit = rateLimit({
  windowMs: 15 * 60 * 1000,  // 15 minutes
  max: 10,
  message: { error: { code: 'RATE_LIMITED', message: 'Too many login attempts. Try in 15 minutes.', retryable: false } },
});
```

### 4.5 utils/http.ts

```typescript
import { Request, Response, NextFunction } from 'express';

/** Wraps async route handlers — eliminates try/catch in every controller */
export const asyncHandler =
  (fn: (req: Request, res: Response, next: NextFunction) => Promise<void>) =>
  (req: Request, res: Response, next: NextFunction): void => {
    Promise.resolve(fn(req, res, next)).catch(next);
  };
```

---

## 5. Models (Mongoose)

### 5.1 models/user.model.ts

```typescript
import mongoose, { Schema, Document } from 'mongoose';

export interface IUser extends Document {
  role:          'center_head' | 'therapist' | 'parent';
  phone:         string;
  email?:        string;
  password_hash: string;
  name:          string;
  photo_url?:    string;
  is_verified:   boolean;
  created_at:    Date;
  updated_at:    Date;
}

const userSchema = new Schema<IUser>({
  role:          { type: String, enum: ['center_head','therapist','parent'], required: true },
  phone:         { type: String, required: true, unique: true, index: true, trim: true },
  email:         { type: String, sparse: true, lowercase: true, trim: true },
  password_hash: { type: String, required: true },
  name:          { type: String, required: true, trim: true },
  photo_url:     { type: String },
  is_verified:   { type: Boolean, default: false },
}, { timestamps: { createdAt: 'created_at', updatedAt: 'updated_at' } });

userSchema.set('toJSON', {
  transform: (_, ret) => { delete ret.password_hash; return ret; },
});

export const UserModel = mongoose.model<IUser>('User', userSchema);
```

### 5.2 models/child.model.ts

```typescript
import mongoose, { Schema, Document } from 'mongoose';

export interface IChild extends Document {
  name:            string;
  nickname?:       string;
  dob:             Date;
  gender:          string;
  photo_url?:      string;
  diagnosis:       string[];
  severity:        'mild' | 'moderate' | 'high_support';
  primary_concerns: string[];
  therapy_targets: string[];
  therapist_id?:   mongoose.Types.ObjectId;
  parent_id:       mongoose.Types.ObjectId;
  center_id?:      mongoose.Types.ObjectId;
  medical: {
    birth_history:        string;
    milestones_delay:     boolean;
    hearing_issues:       boolean;
    vision_issues:        boolean;
    current_medications:  string[];
  };
  emergency_contact: { name: string; phone: string };
  documents:         { url: string; type: string; uploaded_at: Date }[];
  home_context: {
    primary_caregiver:  string;
    screen_time_hours:  number;
    play_type:          string;
    parent_involvement: string;
  };
  goals: { priorities: string[]; timeline_months: number };
  consent_record: { given_at: Date; given_by: string };
}

const childSchema = new Schema<IChild>({
  name:             { type: String, required: true, trim: true },
  nickname:         { type: String, trim: true },
  dob:              { type: Date, required: true },
  gender:           { type: String, enum: ['boy','girl','other'], required: true },
  photo_url:        { type: String },
  diagnosis:        [{ type: String }],
  severity:         { type: String, enum: ['mild','moderate','high_support'] },
  primary_concerns: [{ type: String }],
  therapy_targets:  [{ type: String }],
  therapist_id:     { type: Schema.Types.ObjectId, ref: 'User' },
  parent_id:        { type: Schema.Types.ObjectId, ref: 'User', required: true },
  center_id:        { type: Schema.Types.ObjectId },
  medical: {
    birth_history:       { type: String, default: 'normal' },
    milestones_delay:    { type: Boolean, default: false },
    hearing_issues:      { type: Boolean, default: false },
    vision_issues:       { type: Boolean, default: false },
    current_medications: [{ type: String }],
  },
  emergency_contact: { name: String, phone: String },
  documents: [{
    url: String, type: String, uploaded_at: { type: Date, default: Date.now },
  }],
  home_context: {
    primary_caregiver:  { type: String, default: '' },
    screen_time_hours:  { type: Number, default: 0 },
    play_type:          { type: String, enum: ['alone','guided','group'], default: 'guided' },
    parent_involvement: { type: String, enum: ['low','medium','high'], default: 'medium' },
  },
  goals: {
    priorities:      [{ type: String }],
    timeline_months: { type: Number, default: 6 },
  },
  consent_record: { given_at: Date, given_by: String },
}, { timestamps: true });

childSchema.index({ parent_id:    1 });
childSchema.index({ therapist_id: 1 });

export const ChildModel = mongoose.model<IChild>('Child', childSchema);
```

### 5.3 models/session.model.ts

```typescript
import mongoose, { Schema, Document } from 'mongoose';

const sessionNotesSchema = new Schema({
  mood:               { type: String, enum: ['sad','calm','happy','excited'] },
  attention_score:    { type: Number, min: 1, max: 10 },
  communication_score:{ type: Number, min: 1, max: 10 },
  motor_score:        { type: Number, min: 1, max: 10 },
  behavior_score:     { type: Number, min: 1, max: 10 },
  activities:         [{ type: String }],
  notes:              { type: String },
  submitted_at:       { type: Date, default: Date.now },
}, { _id: false });

const sessionSchema = new Schema({
  child_id:     { type: Schema.Types.ObjectId, ref: 'Child', required: true },
  therapist_id: { type: Schema.Types.ObjectId, ref: 'User',  required: true },
  scheduled_at: { type: Date, required: true },
  type:         { type: String, enum: ['speech','ot','behavior','special_ed'], required: true },
  mode:         { type: String, enum: ['online','offline'], default: 'offline' },
  duration_min: { type: Number, default: 45 },
  status:       { type: String, enum: ['scheduled','completed','cancelled'], default: 'scheduled' },
  notes:        { type: sessionNotesSchema },
}, { timestamps: true });

sessionSchema.index({ therapist_id: 1, scheduled_at: -1 });
sessionSchema.index({ child_id:     1, scheduled_at: -1 });

export const SessionModel = mongoose.model('Session', sessionSchema);
```

### 5.4 models/home-plan.model.ts

```typescript
import mongoose, { Schema } from 'mongoose';

const taskSchema = new Schema({
  task_id:      { type: String, required: true },
  title:        { type: String, required: true },
  description:  { type: String },
  icon:         { type: String, default: '✅' },
  time_of_day:  { type: String, enum: ['morning','afternoon','evening'], required: true },
  duration_min: { type: Number, required: true },
  frequency:    { type: String, enum: ['daily','weekly'], default: 'daily' },
  target_count: { type: Number, default: 1 },
}, { _id: false });

const homePlanSchema = new Schema({
  child_id:      { type: Schema.Types.ObjectId, ref: 'Child', required: true },
  therapist_id:  { type: Schema.Types.ObjectId, ref: 'User',  required: true },
  start_date:    { type: Date, required: true },
  end_date:      { type: Date, required: true },
  tasks:         [taskSchema],
  ai_draft_diff: { type: Schema.Types.Mixed },    // what therapist changed from AI
  is_active:     { type: Boolean, default: true },
}, { timestamps: true });

homePlanSchema.index({ child_id: 1, is_active: 1 });

export const HomePlanModel = mongoose.model('HomePlan', homePlanSchema);
```

### 5.5 models/verification.model.ts

```typescript
import mongoose, { Schema } from 'mongoose';

const verificationSchema = new Schema({
  log_id:       { type: Schema.Types.ObjectId, required: true },
  log_type:     { type: String, enum: ['home','diet','attendance'], required: true },
  child_id:     { type: Schema.Types.ObjectId, ref: 'Child', required: true },
  verified_by:  { type: Schema.Types.ObjectId, ref: 'User' },
  status:       { type: String, enum: ['pending','approved','rejected'], default: 'pending' },
  remarks:      { type: String },
  verified_at:  { type: Date },
}, { timestamps: true });

verificationSchema.index({ status: 1, created_at: -1 });

export const VerificationModel = mongoose.model('Verification', verificationSchema);
```

### 5.6 models/ai-call.model.ts

```typescript
import mongoose, { Schema } from 'mongoose';

const aiCallSchema = new Schema({
  called_by:        { type: Schema.Types.ObjectId, ref: 'User', required: true },
  child_id:         { type: Schema.Types.ObjectId, ref: 'Child', required: true },
  endpoint:         { type: String, enum: ['/ai/plan','/ai/insights','/ai/report'], required: true },
  model:            { type: String, required: true },
  input_tokens:     { type: Number, required: true },
  output_tokens:    { type: Number, required: true },
  latency_ms:       { type: Number },
  prompt_id:        { type: String },
  redacted_request: { type: Schema.Types.Mixed },
  response_summary: { type: String },
  cost_usd:         { type: Number },
}, { timestamps: { createdAt: 'created_at', updatedAt: false } });

export const AiCallModel = mongoose.model('AiCall', aiCallSchema);
```

---

## 6. Modules (Full Auth + Children)

### 6.1 modules/auth/auth.schema.ts

```typescript
import { z } from 'zod';

export const RegisterSchema = z.object({
  name:     z.string().min(2).max(100).trim(),
  phone:    z.string().regex(/^\+?[1-9]\d{9,14}$/, 'Invalid phone number'),
  password: z.string().min(6).max(100),
  role:     z.enum(['center_head', 'therapist', 'parent']),
});

export const LoginSchema = z.object({
  phone:    z.string(),
  password: z.string(),
});

export const RefreshSchema = z.object({
  refreshToken: z.string(),
});

export type RegisterInput = z.infer<typeof RegisterSchema>;
export type LoginInput    = z.infer<typeof LoginSchema>;
```

### 6.2 modules/auth/auth.service.ts

```typescript
import bcrypt         from 'bcrypt';
import jwt            from 'jsonwebtoken';
import { UserModel }  from '../../models/user.model';
import { AppError }   from '../../middleware/error';
import { env }        from '../../config/env';
import type { RegisterInput, LoginInput } from './auth.schema';

export async function register(input: RegisterInput) {
  const existing = await UserModel.findOne({ phone: input.phone });
  if (existing) throw new AppError('CONFLICT', 'Phone number already registered');

  const hash = await bcrypt.hash(input.password, 12);
  const user = await UserModel.create({
    name: input.name, phone: input.phone,
    password_hash: hash, role: input.role,
  });
  return { user, tokens: issueTokens(user.id, user.role) };
}

export async function login(input: LoginInput) {
  const user = await UserModel.findOne({ phone: input.phone });
  if (!user) throw new AppError('UNAUTHORIZED', 'Invalid phone or password');

  const ok = await bcrypt.compare(input.password, user.password_hash);
  if (!ok) throw new AppError('UNAUTHORIZED', 'Invalid phone or password');

  return { user, tokens: issueTokens(user.id, user.role) };
}

export async function refreshTokens(refreshToken: string) {
  let payload: any;
  try {
    payload = jwt.verify(refreshToken, env.JWT_REFRESH_SECRET);
  } catch {
    throw new AppError('UNAUTHORIZED', 'Refresh token invalid or expired');
  }
  const user = await UserModel.findById(payload.sub);
  if (!user) throw new AppError('UNAUTHORIZED', 'User not found');
  return issueTokens(user.id, user.role);
}

function issueTokens(userId: string, role: string) {
  const payload = { sub: userId, role };
  const accessToken  = jwt.sign(payload, env.JWT_ACCESS_SECRET,  { expiresIn: env.ACCESS_TOKEN_EXPIRES  as any });
  const refreshToken = jwt.sign(payload, env.JWT_REFRESH_SECRET, { expiresIn: env.REFRESH_TOKEN_EXPIRES as any });
  return { accessToken, refreshToken };
}
```

### 6.3 modules/auth/auth.controller.ts

```typescript
import { Request, Response } from 'express';
import * as AuthService       from './auth.service';
import { RegisterSchema, LoginSchema, RefreshSchema } from './auth.schema';
import { asyncHandler } from '../../utils/http';

export const register = asyncHandler(async (req, res) => {
  const input        = RegisterSchema.parse(req.body);
  const { user, tokens } = await AuthService.register(input);
  res.status(201).json({ user, ...tokens });
});

export const login = asyncHandler(async (req, res) => {
  const input             = LoginSchema.parse(req.body);
  const { user, tokens }  = await AuthService.login(input);
  res.json({ user, ...tokens });
});

export const refresh = asyncHandler(async (req, res) => {
  const { refreshToken } = RefreshSchema.parse(req.body);
  const tokens           = await AuthService.refreshTokens(refreshToken);
  res.json(tokens);
});

export const logout = asyncHandler(async (req, res) => {
  // In V2: revoke refresh token in Redis blocklist
  res.json({ message: 'Logged out successfully' });
});
```

### 6.4 modules/auth/auth.routes.ts

```typescript
import { Router }       from 'express';
import { authRateLimit } from '../../middleware/rate-limit';
import * as AuthCtrl    from './auth.controller';

const router = Router();

router.post('/register', authRateLimit, AuthCtrl.register);
router.post('/login',    authRateLimit, AuthCtrl.login);
router.post('/refresh',  AuthCtrl.refresh);
router.post('/logout',   AuthCtrl.logout);

export default router;
```

### 6.5 modules/children/children.schema.ts

```typescript
import { z } from 'zod';

export const CreateChildSchema = z.object({
  name:             z.string().min(1).max(100).trim(),
  nickname:         z.string().optional(),
  dob:              z.string().datetime({ offset: true }),
  gender:           z.enum(['boy','girl','other']),
  diagnosis:        z.array(z.string()).min(1),
  severity:         z.enum(['mild','moderate','high_support']),
  therapy_targets:  z.array(z.string()).min(1),
  parent_id:        z.string().length(24),
  home_context:     z.object({
    primary_caregiver:  z.string().optional(),
    screen_time_hours:  z.number().min(0).max(24).default(0),
    play_type:          z.enum(['alone','guided','group']).default('guided'),
    parent_involvement: z.enum(['low','medium','high']).default('medium'),
  }).optional(),
  goals: z.object({
    priorities:       z.array(z.string()).optional(),
    timeline_months:  z.number().default(6),
  }).optional(),
  consent_record: z.object({
    given_at: z.string().datetime({ offset: true }),
    given_by: z.string(),
  }),
});

export type CreateChildInput = z.infer<typeof CreateChildSchema>;
```

### 6.6 modules/children/children.service.ts

```typescript
import mongoose                       from 'mongoose';
import { ChildModel }                  from '../../models/child.model';
import { AppError }                    from '../../middleware/error';
import type { CreateChildInput }       from './children.schema';
import type { AuthPayload }            from '../../middleware/auth';

export async function listChildren(user: AuthPayload) {
  const filter = user.role === 'therapist'
    ? { therapist_id: user.sub }
    : user.role === 'parent'
    ? { parent_id: user.sub }
    : {};                                // center_head sees all

  return ChildModel.find(filter).sort({ created_at: -1 }).lean();
}

export async function getChild(id: string, user: AuthPayload) {
  const child = await ChildModel.findById(id).lean();
  if (!child) throw new AppError('NOT_FOUND', 'Child not found');

  // Ownership check
  const ownedByTherapist = user.role === 'therapist' &&
    child.therapist_id?.toString() === user.sub;
  const ownedByParent = user.role === 'parent' &&
    child.parent_id.toString() === user.sub;
  const isAdmin = user.role === 'center_head';

  if (!ownedByTherapist && !ownedByParent && !isAdmin) {
    throw new AppError('FORBIDDEN', 'Access denied');
  }
  return child;
}

export async function createChild(input: CreateChildInput, user: AuthPayload) {
  if (user.role !== 'center_head') {
    throw new AppError('FORBIDDEN', 'Only center head can create children');
  }
  const child = await ChildModel.create({
    ...input,
    dob: new Date(input.dob),
  });
  return child;
}

export async function updateChild(id: string, updates: Partial<CreateChildInput>, user: AuthPayload) {
  const child = await ChildModel.findById(id);
  if (!child) throw new AppError('NOT_FOUND', 'Child not found');

  // Only therapist or center_head can update
  if (user.role === 'parent') throw new AppError('FORBIDDEN', 'Access denied');

  Object.assign(child, updates);
  return child.save();
}
```

### 6.7 modules/children/children.controller.ts

```typescript
import * as ChildService        from './children.service';
import { CreateChildSchema }    from './children.schema';
import { asyncHandler }         from '../../utils/http';

export const list = asyncHandler(async (req, res) => {
  const children = await ChildService.listChildren(req.user!);
  res.json(children);
});

export const get = asyncHandler(async (req, res) => {
  const child = await ChildService.getChild(req.params.id, req.user!);
  res.json(child);
});

export const create = asyncHandler(async (req, res) => {
  const input = CreateChildSchema.parse(req.body);
  const child = await ChildService.createChild(input, req.user!);
  res.status(201).json(child);
});

export const update = asyncHandler(async (req, res) => {
  const child = await ChildService.updateChild(req.params.id, req.body, req.user!);
  res.json(child);
});
```

### 6.8 modules/children/children.routes.ts

```typescript
import { Router }         from 'express';
import { requireAuth }    from '../../middleware/auth';
import * as ChildCtrl     from './children.controller';

const router = Router();
router.use(requireAuth);

router.get('/',    ChildCtrl.list);
router.post('/',   ChildCtrl.create);
router.get('/:id', ChildCtrl.get);
router.patch('/:id', ChildCtrl.update);

export default router;
```

---

## 7. Sessions Module

### 7.1 modules/sessions/sessions.service.ts

```typescript
import { SessionModel }  from '../../models/session.model';
import { AppError }      from '../../middleware/error';
import type { AuthPayload } from '../../middleware/auth';
import { snapshotQueue }  from '../../jobs/queues';

export async function getUpcomingSessions(user: AuthPayload) {
  const now = new Date();
  const filter = user.role === 'therapist'
    ? { therapist_id: user.sub, scheduled_at: { $gte: now }, status: 'scheduled' }
    : { child_id: { $exists: true }, scheduled_at: { $gte: now }, status: 'scheduled' };

  return SessionModel.find(filter)
    .sort({ scheduled_at: 1 })
    .limit(20)
    .lean();
}

export async function createSession(data: {
  child_id:     string;
  scheduled_at: string;
  type:         string;
  mode?:        string;
  duration_min?: number;
}, user: AuthPayload) {
  if (user.role !== 'therapist') {
    throw new AppError('FORBIDDEN', 'Only therapists can create sessions');
  }
  return SessionModel.create({
    ...data,
    therapist_id: user.sub,
    scheduled_at: new Date(data.scheduled_at),
  });
}

export async function submitNotes(sessionId: string, notes: {
  mood:               string;
  attention_score:    number;
  communication_score: number;
  motor_score:        number;
  behavior_score:     number;
  activities:         string[];
  notes?:             string;
}, user: AuthPayload) {
  if (user.role !== 'therapist') {
    throw new AppError('FORBIDDEN', 'Only therapists can submit session notes');
  }
  const session = await SessionModel.findById(sessionId);
  if (!session) throw new AppError('NOT_FOUND', 'Session not found');
  if (session.therapist_id.toString() !== user.sub) {
    throw new AppError('FORBIDDEN', 'This is not your session');
  }

  session.notes  = notes as any;
  session.status = 'completed';
  await session.save();

  // Trigger background snapshot rebuild
  await snapshotQueue.add('rebuild', { childId: session.child_id.toString() });

  return session;
}
```

---

## 8. Verification Module

### 8.1 modules/verification/verification.service.ts

```typescript
import { VerificationModel }  from '../../models/verification.model';
import { HomePlanModel }      from '../../models/home-plan.model';
import { AppError }           from '../../middleware/error';
import type { AuthPayload }   from '../../middleware/auth';
import { chunkQueue }         from '../../jobs/queues';

export async function getPending(user: AuthPayload) {
  if (user.role !== 'center_head') {
    throw new AppError('FORBIDDEN', 'Only center head can view verification queue');
  }
  return VerificationModel.find({ status: 'pending' })
    .sort({ created_at: -1 })
    .lean();
}

export async function verify(logId: string, decision: {
  status: 'approved' | 'rejected';
  remarks?: string;
}, user: AuthPayload) {
  if (user.role !== 'center_head') {
    throw new AppError('FORBIDDEN', 'Only center head can verify');
  }

  const record = await VerificationModel.findOne({ log_id: logId });
  if (!record) throw new AppError('NOT_FOUND', 'Verification record not found');
  if (record.status !== 'pending') throw new AppError('CONFLICT', 'Already verified');

  record.status      = decision.status;
  record.remarks     = decision.remarks;
  record.verified_by = user.sub as any;
  record.verified_at = new Date();
  await record.save();

  // Queue RAG chunk for this verification outcome
  await chunkQueue.add('verification-outcome', {
    verificationId: record.id,
    status:         decision.status,
    childId:        record.child_id.toString(),
  });

  return record;
}
```

---

## 9. AI Orchestration Module

### 9.1 modules/ai/ai.service.ts

```typescript
import axios           from 'axios';
import { ChildModel }  from '../../models/child.model';
import { AiCallModel } from '../../models/ai-call.model';
import { AppError }    from '../../middleware/error';
import { env }         from '../../config/env';
import type { AuthPayload } from '../../middleware/auth';

const aiHttp = axios.create({
  baseURL: env.AI_SERVICE_URL,
  headers: { 'X-AI-Service-Token': env.AI_SERVICE_TOKEN },
  timeout: 60_000,
});

export async function generatePlan(childId: string, therapyType: string, user: AuthPayload) {
  if (user.role !== 'therapist') {
    throw new AppError('FORBIDDEN', 'Only therapists can generate plans');
  }

  // 1. Load current child snapshot
  const snapshotRes = await aiHttp.get(`/snapshot/current/${childId}`);
  const snapshot    = snapshotRes.data;

  // 2. Retrieve relevant RAG chunks
  const chunksRes = await aiHttp.post('/retrieve', {
    child_id: childId, query: `therapy plan ${therapyType}`, top_k: 8,
  });

  // 3. Call plan generation
  const startMs  = Date.now();
  const planRes  = await aiHttp.post('/plan/generate', {
    snapshot, chunks: chunksRes.data, therapy_type: therapyType,
  });
  const latency  = Date.now() - startMs;

  // 4. Audit log (mandatory — never skip)
  await AiCallModel.create({
    called_by:        user.sub,
    child_id:         childId,
    endpoint:         '/ai/plan',
    model:            planRes.data.model,
    input_tokens:     planRes.data.usage?.input_tokens  ?? 0,
    output_tokens:    planRes.data.usage?.output_tokens ?? 0,
    latency_ms:       latency,
    prompt_id:        planRes.data.prompt_id,
    response_summary: `Generated ${planRes.data.plan?.home_tasks?.length ?? 0} home tasks`,
    cost_usd:         planRes.data.cost_usd ?? 0,
  });

  return { draft_id: planRes.data.draft_id, plan: planRes.data.plan };
}

export async function approvePlan(draftId: string, finalTasks: unknown[], user: AuthPayload) {
  if (user.role !== 'therapist') {
    throw new AppError('FORBIDDEN', 'Only therapists can approve plans');
  }

  const res = await aiHttp.post(`/plan/${draftId}/approve`, {
    final_tasks: finalTasks, approved_by: user.sub,
  });

  // Chunk the therapist correction for RAG learning
  await chunkQueue.add('therapist-correction', {
    draftId, diff: res.data.diff, childId: res.data.child_id,
  });

  return res.data;
}

// Avoid circular import — declare chunkQueue inline
import { chunkQueue } from '../../jobs/queues';
```

---

## 10. Background Jobs (BullMQ)

### 10.1 jobs/queues.ts

```typescript
import { Queue }  from 'bullmq';
import { redis }  from '../config/redis';

const opts = { connection: redis };

export const snapshotQueue = new Queue('snapshot.rebuild', opts);
export const chunkQueue    = new Queue('chunk.from-event', opts);
export const embedQueue    = new Queue('embed.refresh',    opts);
export const reportQueue   = new Queue('report.monthly',   opts);
```

### 10.2 jobs/snapshot.job.ts

```typescript
import { Worker } from 'bullmq';
import axios      from 'axios';
import { redis }  from '../config/redis';
import { env }    from '../config/env';
import logger     from '../utils/logger';

const aiHttp = axios.create({
  baseURL: env.AI_SERVICE_URL,
  headers: { 'X-AI-Service-Token': env.AI_SERVICE_TOKEN },
});

export const snapshotWorker = new Worker(
  'snapshot.rebuild',
  async (job) => {
    const { childId } = job.data as { childId: string };
    logger.info({ childId }, 'Rebuilding snapshot');

    await aiHttp.post(`/snapshot/rebuild/${childId}`);
    logger.info({ childId }, 'Snapshot rebuilt');
  },
  { connection: redis, concurrency: 5 },
);

snapshotWorker.on('failed', (job, err) => {
  logger.error({ jobId: job?.id, err }, 'Snapshot job failed');
});
```

---

## 11. Tests

### 11.1 tests/setup.ts

```typescript
import { MongoMemoryServer } from 'mongodb-memory-server';
import mongoose               from 'mongoose';
import { beforeAll, afterAll, afterEach } from 'vitest';

let mongo: MongoMemoryServer;

beforeAll(async () => {
  mongo = await MongoMemoryServer.create();
  await mongoose.connect(mongo.getUri());
});

afterEach(async () => {
  const collections = mongoose.connection.collections;
  for (const key in collections) {
    await collections[key].deleteMany({});
  }
});

afterAll(async () => {
  await mongoose.disconnect();
  await mongo.stop();
});
```

### 11.2 tests/auth.test.ts

```typescript
import { describe, it, expect } from 'vitest';
import request from 'supertest';
import app from '../src/app';
import './setup';

describe('POST /api/v1/auth/register', () => {
  it('creates a user and returns tokens', async () => {
    const res = await request(app).post('/api/v1/auth/register').send({
      name: 'Dr. Sharma', phone: '+919876543210', password: 'secret123', role: 'therapist',
    });
    expect(res.status).toBe(201);
    expect(res.body.accessToken).toBeDefined();
    expect(res.body.user.password_hash).toBeUndefined();  // never exposed
  });

  it('rejects duplicate phone', async () => {
    const data = { name: 'Test', phone: '+919876543211', password: 'abc123', role: 'parent' };
    await request(app).post('/api/v1/auth/register').send(data);
    const res = await request(app).post('/api/v1/auth/register').send(data);
    expect(res.status).toBe(409);
    expect(res.body.error.code).toBe('CONFLICT');
  });
});

describe('POST /api/v1/auth/login', () => {
  it('logs in with correct credentials', async () => {
    await request(app).post('/api/v1/auth/register').send({
      name: 'Parent A', phone: '+919000000001', password: 'mypassword', role: 'parent',
    });
    const res = await request(app).post('/api/v1/auth/login').send({
      phone: '+919000000001', password: 'mypassword',
    });
    expect(res.status).toBe(200);
    expect(res.body.accessToken).toBeDefined();
  });

  it('rejects wrong password', async () => {
    const res = await request(app).post('/api/v1/auth/login').send({
      phone: '+919000000001', password: 'wrongpass',
    });
    expect(res.status).toBe(401);
  });
});
```

---

## 12. Local Dev Setup

```bash
# 1. Clone and install
cd backend
pnpm install          # or npm install

# 2. Copy env
cp .env.example .env  # fill JWT secrets, AWS keys

# 3. Generate JWT secrets
node -e "console.log(require('crypto').randomBytes(32).toString('hex'))"
# Run twice — one for ACCESS, one for REFRESH

# 4. Start Mongo + Redis
docker compose up -d

# 5. Run API
pnpm dev
# → http://localhost:8000
# → http://localhost:8000/health

# 6. View OpenAPI docs
# Add zod-to-openapi and serve at /docs (see README_BACKEND.md §8)
```

---

## 13. Error Response Format (Canonical)

Every error from the API returns this exact shape. Flutter pattern-matches on `code`.

```json
{
  "error": {
    "code":       "INVALID_INPUT",
    "message":    "Validation failed",
    "details":    { "phone": ["Invalid phone number"] },
    "retryable":  false,
    "request_id": "req_abc123"
  }
}
```

| code | HTTP | When |
|------|------|------|
| `INVALID_INPUT` | 400 | Zod validation failure |
| `UNAUTHORIZED` | 401 | Bad/expired token or wrong credentials |
| `FORBIDDEN` | 403 | Correct token, wrong role |
| `NOT_FOUND` | 404 | Entity doesn't exist |
| `CONFLICT` | 409 | Duplicate (phone, etc.) |
| `RATE_LIMITED` | 429 | Too many requests |
| `SERVER_ERROR` | 500 | Unhandled exception |
| `AI_FAILURE` | 502 | AI service unreachable |

---

*Last revised: May 2026. Pair with Doc 1 (Architecture) and Doc 4 (AI Layer).*
