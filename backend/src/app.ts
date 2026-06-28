import express            from 'express';
import helmet            from 'helmet';
import cors              from 'cors';
import { env }           from './config/env';
import { generalRateLimit } from './middleware/rate-limit';
import { errorHandler }  from './middleware/error';
import authRoutes        from './modules/auth/auth.routes';
import usersRoutes       from './modules/users/users.routes';
import childrenRoutes    from './modules/children/children.routes';
import assessmentsRoutes from './modules/assessments/assessments.routes';
import sessionsRoutes    from './modules/sessions/sessions.routes';
import homePlansRoutes   from './modules/home-plans/home-plans.routes';
import dietPlansRoutes   from './modules/diet-plans/diet-plans.routes';
import verificationRoutes from './modules/verification/verification.routes';
import alertsRoutes      from './modules/alerts/alerts.routes';
import concernsRoutes    from './modules/concerns/concerns.routes';
import goalsRoutes       from './modules/goals/goals.routes';
import reviewsRoutes     from './modules/reviews/reviews.routes';
import videosRoutes      from './modules/videos/videos.routes';
import dietRequestsRoutes    from './modules/diet-requests/diet-requests.routes';
import attendanceRoutes      from './modules/attendance/attendance.routes';
import notificationsRoutes   from './modules/notifications/notifications.routes';
import googleRoutes          from './modules/google/google.routes';
import ragRoutes             from './modules/rag/rag.routes';
import reportsRoutes         from './modules/reports/reports.routes';
import aiRoutes          from './modules/ai/ai.routes';
import chatbotRoutes     from './modules/chatbot/chatbot.routes';
import paymentsRoutes    from './modules/payments/payments.routes';
import settingsRoutes    from './modules/settings/settings.routes';

const app = express();

app.disable('x-powered-by');

const allowedOrigins = env.ALLOWED_ORIGIN
  .split(',')
  .map((origin) => origin.trim())
  .filter(Boolean);

if (env.NODE_ENV === 'production' && allowedOrigins.includes('*')) {
  throw new Error('ALLOWED_ORIGIN must not be "*" in production');
}

app.use(helmet({
  frameguard: { action: 'deny' },
  referrerPolicy: { policy: 'strict-origin-when-cross-origin' },
  contentSecurityPolicy: {
    directives: {
      defaultSrc: ["'self'"],
      baseUri:    ["'self'"],
      objectSrc:  ["'none'"],
      frameAncestors: ["'none'"],
      imgSrc:     ["'self'", 'data:', 'https:'],
      connectSrc: ["'self'", ...allowedOrigins.filter((origin) => origin !== '*')],
      scriptSrc:  ["'self'"],
      styleSrc:   ["'self'", "'unsafe-inline'"],
    },
  },
}));
app.use(cors({
  origin(origin, cb) {
    if (!origin) return cb(null, true);
    if (allowedOrigins.includes('*') || allowedOrigins.includes(origin)) return cb(null, true);
    return cb(null, false);
  },
  methods: ['GET', 'POST', 'PUT', 'PATCH', 'DELETE', 'OPTIONS'],
  credentials: true,
}));
app.use(generalRateLimit);

app.use(express.json({ limit: '10mb' }));
app.use(express.urlencoded({ extended: true }));

app.get('/health', (_, res) => res.json({ status: 'ok', ts: Date.now() }));

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
app.use(`${api}/concerns`,     concernsRoutes);
app.use(`${api}/goals`,        goalsRoutes);
app.use(`${api}/reviews`,      reviewsRoutes);
app.use(`${api}/videos`,        videosRoutes);
app.use(`${api}/diet-requests`,  dietRequestsRoutes);
app.use(`${api}/attendance`,     attendanceRoutes);
app.use(`${api}/notifications`,  notificationsRoutes);
app.use(`${api}/google`,         googleRoutes);
app.use(`${api}/rag`,            ragRoutes);
app.use(`${api}/reports`,        reportsRoutes);
app.use(`${api}/ai`,           aiRoutes);
app.use(`${api}/chatbot`,      chatbotRoutes);
app.use(`${api}/payments`,     paymentsRoutes);
app.use(`${api}/settings`,     settingsRoutes);

app.use(errorHandler);

export default app;
