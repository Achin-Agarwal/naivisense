import { Worker }             from 'bullmq';
import { redis }              from '../config/redis';
import logger                 from '../utils/logger';
import { ChildModel }         from '../models/child.model';
import { ReviewModel }        from '../models/review.model';
import { SessionModel }       from '../models/session.model';
import { AttendanceModel }    from '../models/attendance.model';
import { GoalModel }          from '../models/goal.model';
import { AssessmentModel }    from '../models/assessment.model';
import { ChildSnapshotModel } from '../models/child-snapshot.model';
import mongoose               from 'mongoose';

async function generateMonthlyReportForChild(
  childId: string,
  periodStart: Date,
  periodEnd: Date,
  systemUserId: mongoose.Types.ObjectId,
): Promise<void> {
  const existing = await ReviewModel.findOne({
    child_id:    childId,
    review_type: 'monthly',
    period_start: periodStart,
  }).lean();

  if (existing) {
    logger.info({ childId, period: periodStart }, 'Monthly report already exists — skipping');
    return;
  }

  const [sessions, attendance, goals, latestAssessment, snapshot] = await Promise.all([
    SessionModel.find({
      child_id:     childId,
      scheduled_at: { $gte: periodStart, $lte: periodEnd },
      status:       'completed',
    }).lean(),
    AttendanceModel.find({
      child_id: childId,
      date:     { $gte: periodStart, $lte: periodEnd },
    }).lean(),
    GoalModel.find({ child_id: childId }).lean(),
    AssessmentModel.findOne({ child_id: childId, is_complete: true })
      .sort({ date: -1 }).lean(),
    ChildSnapshotModel.findOne({ child_id: childId, is_current: true }).lean(),
  ]);

  const totalSessions   = sessions.length;
  const presentCount    = attendance.filter((a) => a.status === 'present').length;
  const attendancePct   = attendance.length > 0
    ? Math.round((presentCount / attendance.length) * 100)
    : 0;

  const activeGoals     = goals.filter((g) => g.status === 'active').map((g) => g.title);
  const completedGoals  = goals.filter((g) => g.status === 'completed').map((g) => g.title);

  const avgAttention    = sessions.reduce((s, r) => s + (r.notes?.attention_score ?? 0), 0)
    / (totalSessions || 1);
  const avgCommunication = sessions.reduce((s, r) => s + (r.notes?.communication_score ?? 0), 0)
    / (totalSessions || 1);

  const observations: string[] = [
    `Sessions completed: ${totalSessions}`,
    `Attendance: ${presentCount}/${attendance.length} (${attendancePct}%)`,
  ];

  if (activeGoals.length > 0) {
    observations.push(`Active goals: ${activeGoals.join(', ')}`);
  }
  if (completedGoals.length > 0) {
    observations.push(`Goals completed this month: ${completedGoals.join(', ')}`);
  }
  if (totalSessions > 0) {
    observations.push(
      `Average scores — Attention: ${avgAttention.toFixed(1)}/10, ` +
      `Communication: ${avgCommunication.toFixed(1)}/10`,
    );
  }
  if (latestAssessment) {
    observations.push(
      `Latest assessment: ${latestAssessment.type} — ${latestAssessment.overall_score_pct?.toFixed(0) ?? 'N/A'}% overall`,
    );
  }
  if (snapshot?.ai_insights?.recommendations?.length) {
    observations.push(
      `AI recommendations: ${snapshot.ai_insights.recommendations.slice(0, 2).join('; ')}`,
    );
  }

  await ReviewModel.create({
    child_id:          childId,
    review_type:       'monthly',
    created_by:        systemUserId,
    period_start:      periodStart,
    period_end:        periodEnd,
    text_observations: observations.join('\n'),
    status:            'draft',
    video_ids:         [],
  });

  logger.info({ childId, period: periodStart }, 'Monthly report generated');
}

export const reportWorker = new Worker(
  'report.monthly',
  async (job) => {
    logger.info({ jobId: job.id }, 'Monthly report job started');

    // Period: previous calendar month
    const now         = new Date();
    const periodEnd   = new Date(now.getFullYear(), now.getMonth(), 0, 23, 59, 59); // last day of prev month
    const periodStart = new Date(now.getFullYear(), now.getMonth() - 1, 1);         // first day of prev month

    // Use a fixed system ObjectId as the "created_by" for auto-generated reports
    const systemUserId = new mongoose.Types.ObjectId('000000000000000000000001');

    const children = await ChildModel.find({}).select('_id').lean();
    logger.info({ childCount: children.length }, 'Generating monthly reports');

    await Promise.allSettled(
      children.map((c) =>
        generateMonthlyReportForChild(
          c._id.toString(),
          periodStart,
          periodEnd,
          systemUserId,
        ),
      ),
    );

    logger.info({ jobId: job.id, childCount: children.length }, 'Monthly reports done');
  },
  { connection: redis },
);

reportWorker.on('failed', (job, err) => {
  logger.error({ jobId: job?.id, err }, 'Report job failed');
});
