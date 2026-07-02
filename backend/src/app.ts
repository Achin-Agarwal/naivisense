import express            from 'express';
import helmet            from 'helmet';
import cors              from 'cors';
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
import sessionTimingsRoutes from './modules/session-timings/session-timings.routes';
import alertsRoutes      from './modules/alerts/alerts.routes';
import reportsRoutes     from './modules/reports/reports.routes';
import aiRoutes          from './modules/ai/ai.routes';
import morgan from 'morgan';

const app = express();
app.set("trust proxy", 1);
app.use(morgan('dev'));
app.use(helmet());
app.use(cors({ origin: process.env.ALLOWED_ORIGIN ?? '*', credentials: true }));
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
app.use(`${api}/reports`,      reportsRoutes);
app.use(`${api}/ai`,           aiRoutes);
app.use(`${api}/session-timings`, sessionTimingsRoutes);

app.use(errorHandler);

export default app;
