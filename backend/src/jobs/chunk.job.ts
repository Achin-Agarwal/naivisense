<<<<<<< HEAD
import { Worker } from 'bullmq';
import { env }  from '../config/env';
import logger     from '../utils/logger';
=======
import { Worker }             from 'bullmq';
import { redis }              from '../config/redis';
import logger                 from '../utils/logger';
import { ChildModel }         from '../models/child.model';
import { ChildSnapshotModel } from '../models/child-snapshot.model';
import { AssessmentModel }    from '../models/assessment.model';
import { SessionModel }       from '../models/session.model';
import { AttendanceModel }    from '../models/attendance.model';
import { HomePlanModel }      from '../models/home-plan.model';
import { DietPlanModel }      from '../models/diet-plan.model';
import { HomeTaskLogModel }   from '../models/home-task-log.model';
import { MealLogModel }       from '../models/meal-log.model';
import { GoalModel }          from '../models/goal.model';
import { AlertModel }         from '../models/alert.model';

async function rebuildSnapshot(childId: string): Promise<void> {
  const thirtyDaysAgo = new Date(Date.now() - 30 * 24 * 60 * 60 * 1000);

  const [
    child,
    latestAssessment,
    baselineAssessment,
    recentSessions,
    attendance,
    activePlan,
    activeDietPlan,
    goals,
    openAlerts,
  ] = await Promise.all([
    ChildModel.findById(childId).lean(),
    AssessmentModel.findOne({ child_id: childId, is_complete: true }).sort({ date: -1 }).lean(),
    AssessmentModel.findOne({ child_id: childId, is_complete: true }).sort({ date: 1 }).lean(),
    SessionModel.find({ child_id: childId, status: 'completed', scheduled_at: { $gte: thirtyDaysAgo } })
      .sort({ scheduled_at: -1 }).limit(10).lean(),
    AttendanceModel.find({ child_id: childId, date: { $gte: thirtyDaysAgo } }).lean(),
    HomePlanModel.findOne({ child_id: childId, is_active: true }).lean(),
    DietPlanModel.findOne({ child_id: childId, is_active: true }).lean(),
    GoalModel.find({ child_id: childId }).lean(),
    AlertModel.find({ child_id: childId, status: 'open' }).lean(),
  ]);

  if (!child) {
    logger.warn({ childId }, 'Snapshot rebuild skipped — child not found');
    return;
  }

  // Attendance compliance
  const presentCount = attendance.filter((a) => a.status === 'present').length;
  const attendancePct = attendance.length > 0
    ? Math.round((presentCount / attendance.length) * 100)
    : 0;

  // Home-plan compliance via task logs in last 30 days
  let homePlanPct = 0;
  if (activePlan) {
    const expectedTaskDays = activePlan.tasks.length * 30;
    const approvedLogs = await HomeTaskLogModel.countDocuments({
      child_id:  childId,
      logged_at: { $gte: thirtyDaysAgo },
      status:    'approved',
    });
    homePlanPct = expectedTaskDays > 0
      ? Math.min(100, Math.round((approvedLogs / expectedTaskDays) * 100))
      : 0;
  }

  // Diet-plan compliance via meal logs in last 30 days
  let dietPlanPct = 0;
  if (activeDietPlan) {
    const expectedMealDays = activeDietPlan.meals.length * 30;
    const approvedMeals = await MealLogModel.countDocuments({
      child_id:  childId,
      logged_at: { $gte: thirtyDaysAgo },
      status:    'approved',
    });
    dietPlanPct = expectedMealDays > 0
      ? Math.min(100, Math.round((approvedMeals / expectedMealDays) * 100))
      : 0;
  }

  // Recent wins and issues from session notes
  const recentWins: string[]   = [];
  const recentIssues: string[] = [];
  for (const sess of recentSessions) {
    if (!sess.notes) continue;
    const n = sess.notes;
    if (n.communication_score >= 7 || n.attention_score >= 7) {
      recentWins.push(`Strong session ${sess.scheduled_at.toLocaleDateString()}`);
    }
    if (n.follow_up_required) {
      recentIssues.push(`Follow-up needed from ${sess.scheduled_at.toLocaleDateString()}`);
    }
    if (n.observations) {
      const lower = n.observations.toLowerCase();
      if (lower.includes('regression') || lower.includes('concern') || lower.includes('difficult')) {
        recentIssues.push(n.observations.slice(0, 100));
      } else if (lower.includes('progress') || lower.includes('improve') || lower.includes('success')) {
        recentWins.push(n.observations.slice(0, 100));
      }
    }
  }

  // Risk flags from alerts and low compliance
  const riskFlags: string[] = openAlerts
    .filter((a) => a.priority === 'high')
    .map((a) => a.description.slice(0, 100));

  if (attendancePct < 60) riskFlags.push(`Low attendance: ${attendancePct}%`);
  if (homePlanPct < 40 && activePlan) riskFlags.push(`Low home-plan compliance: ${homePlanPct}%`);

  // Goals summary
  const activeGoals    = goals.filter((g) => g.status === 'active').map((g) => g.title);
  const completedGoals = goals.filter((g) => g.status === 'completed').map((g) => g.title);

  // Strengths from high-scoring session domains
  const strengths: string[] = [];
  const avgAttention    = recentSessions.reduce((s, r) => s + (r.notes?.attention_score ?? 0), 0)
    / (recentSessions.length || 1);
  const avgCommunication = recentSessions.reduce((s, r) => s + (r.notes?.communication_score ?? 0), 0)
    / (recentSessions.length || 1);
  if (avgAttention >= 6)     strengths.push(`Attention avg ${avgAttention.toFixed(1)}/10`);
  if (avgCommunication >= 6) strengths.push(`Communication avg ${avgCommunication.toFixed(1)}/10`);
  if (attendancePct >= 80)   strengths.push(`Strong attendance ${attendancePct}%`);

  // Recommendations
  const recommendations: string[] = [];
  if (homePlanPct < 60)     recommendations.push('Increase home plan task completion');
  if (attendancePct < 80)   recommendations.push('Improve session attendance consistency');
  if (riskFlags.length > 0) recommendations.push('Review open high-priority alerts');
  if (activeGoals.length === 0) recommendations.push('Set active therapy goals');

  const ageYears = child.dob
    ? Math.floor((Date.now() - child.dob.getTime()) / 31536000000)
    : 0;

  const progressLevel = riskFlags.length > 2 ? 'at_risk'
    : completedGoals.length > activeGoals.length ? 'on_track'
    : 'progressing';

  // Deactivate old snapshots and create new one
  await ChildSnapshotModel.updateMany(
    { child_id: childId, is_current: true },
    { $set: { is_current: false } },
  );

  const prevSnapshot = await ChildSnapshotModel.findOne({ child_id: childId })
    .sort({ version: -1 }).lean();
  const newVersion = (prevSnapshot?.version ?? 0) + 1;

  await ChildSnapshotModel.create({
    child_id:   childId,
    is_current: true,
    version:    newVersion,
    updated_at: new Date(),
    profile: {
      age:          ageYears,
      diagnosis:    child.diagnosis,
      notes:        child.primary_concerns.join(', '),
      home_context: child.home_context ?? {},
    },
    baseline_assessment: baselineAssessment
      ? { date: baselineAssessment.date, traits: baselineAssessment.domain_scores ?? {} }
      : { date: new Date(), traits: {} },
    latest_assessment: latestAssessment
      ? {
        date:    latestAssessment.date,
        traits:  latestAssessment.domain_scores ?? {},
        summary: `${latestAssessment.type} — ${latestAssessment.overall_score_pct?.toFixed(0) ?? 0}% overall`,
      }
      : { date: new Date(), traits: {}, summary: 'No assessment yet' },
    trends: {
      attendance:  attendancePct >= 80 ? 'improving' : attendancePct >= 60 ? 'stable' : 'declining',
      home_plan:   homePlanPct  >= 70 ? 'improving' : homePlanPct  >= 40 ? 'stable' : 'declining',
      diet:        dietPlanPct  >= 70 ? 'improving' : dietPlanPct  >= 40 ? 'stable' : 'declining',
    },
    compliance: {
      home_plan_pct:  homePlanPct,
      diet_plan_pct:  dietPlanPct,
      attendance_pct: attendancePct,
    },
    recent_issues: recentIssues.slice(0, 5),
    recent_wins:   recentWins.slice(0, 5),
    ai_insights: {
      progress_level:  progressLevel,
      risk_flags:      riskFlags.slice(0, 5),
      strengths:       strengths.slice(0, 5),
      recommendations: recommendations.slice(0, 5),
    },
    next_goals: activeGoals.slice(0, 5),
  });

  logger.info({ childId, version: newVersion, attendancePct, homePlanPct, dietPlanPct }, 'Snapshot rebuilt');
}
>>>>>>> 621065d26cd57f5b6029f004fd0285600a34d548

export const snapshotWorker = new Worker(
  'snapshot.rebuild',
  async (job) => {
    const { childId } = job.data as { childId: string };
    await rebuildSnapshot(childId);
  },
  { 
    connection: { 
      url: env.REDIS_URL,
      maxRetriesPerRequest: null,
      enableOfflineQueue: false,
      lazyConnect: true,
    }, 
    concurrency: 5 
  },
);

snapshotWorker.on('failed', (job, err) => {
  logger.error({ jobId: job?.id, err }, 'Snapshot job failed');
});