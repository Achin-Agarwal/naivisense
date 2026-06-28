import { AiDraftModel }       from '../../models/ai-draft.model';
import { AiCallModel }        from '../../models/ai-call.model';
import { ChildModel }         from '../../models/child.model';
import { ChildSnapshotModel } from '../../models/child-snapshot.model';
import { SessionModel }       from '../../models/session.model';
import { GoalModel }          from '../../models/goal.model';
import { AlertModel }         from '../../models/alert.model';
import { ConcernModel }       from '../../models/concern.model';
import { HomePlanModel }      from '../../models/home-plan.model';
import { DietPlanModel }      from '../../models/diet-plan.model';
import { ReviewModel }        from '../../models/review.model';
import { AttendanceModel }    from '../../models/attendance.model';
import { AssessmentModel }    from '../../models/assessment.model';
import { AppError }           from '../../middleware/error';
import { generateText, GEMINI_MODEL } from '../../config/gemini';
import { retrieveChunks }     from '../rag/rag.service';
import type { AuthPayload }   from '../../middleware/auth';
import type { AiDraftType }   from '../../models/ai-draft.model';

const AI_ROLES = ['therapist', 'center_head', 'dietician', 'lead_therapist'] as const;

async function buildChildContext(childId: string): Promise<string> {
  const [
    child, snapshot, recentSessions, goals,
    alerts, concerns, activePlan, activeDietPlan,
    recentReviews, recentAttendance, latestAssessment,
  ] = await Promise.all([
    ChildModel.findById(childId).lean(),
    ChildSnapshotModel.findOne({ child_id: childId, is_current: true }).lean(),
    SessionModel.find({ child_id: childId, status: 'completed' })
      .sort({ scheduled_at: -1 }).limit(5).lean(),
    GoalModel.find({ child_id: childId }).lean(),
    AlertModel.find({ child_id: childId, status: 'open' }).sort({ created_at: -1 }).limit(5).lean(),
    ConcernModel.find({ child_id: childId, status: 'open' }).sort({ created_at: -1 }).limit(5).lean(),
    HomePlanModel.findOne({ child_id: childId, is_active: true }).lean(),
    DietPlanModel.findOne({ child_id: childId, is_active: true }).lean(),
    ReviewModel.find({ child_id: childId, status: 'published' }).sort({ created_at: -1 }).limit(2).lean(),
    AttendanceModel.find({ child_id: childId }).sort({ date: -1 }).limit(20).lean(),
    AssessmentModel.findOne({ child_id: childId, is_complete: true }).sort({ date: -1 }).lean(),
  ]);

  if (!child) throw new AppError('NOT_FOUND', 'Child not found');

  const ageYears = Math.floor((Date.now() - child.dob.getTime()) / 31536000000);

  const parts: string[] = [
    `=== CHILD PROFILE ===`,
    `Name: ${child.name}, Age: ${ageYears} years`,
    `Diagnosis: ${child.diagnosis.join(', ')}`,
    `Severity: ${child.severity}`,
    `Primary concerns: ${child.primary_concerns.join(', ')}`,
    `Therapy targets: ${child.therapy_targets.join(', ')}`,
  ];

  if (child.home_context) {
    const hc = child.home_context;
    parts.push(
      `Home context: primary caregiver ${hc.primary_caregiver ?? 'unknown'}, ` +
      `screen time ${hc.screen_time_hours ?? 0}h/day, parent involvement ${hc.parent_involvement ?? 'medium'}`,
    );
  }

  if (latestAssessment) {
    const a = latestAssessment;
    parts.push(
      `\n=== LATEST ASSESSMENT (${a.type}, ${a.date.toLocaleDateString()}) ===`,
      `Overall score: ${a.overall_score_pct.toFixed(0)}%, Risk: ${a.risk_level}`,
    );
    if (a.domain_scores) {
      const d = a.domain_scores;
      parts.push(
        `Domain scores — Attention: ${d.attention}, Communication: ${d.social_communication}, ` +
        `Receptive language: ${d.receptive_language}, Expressive language: ${d.expressive_language}`,
      );
    }
  }

  if (snapshot) {
    const s = snapshot;
    parts.push(
      `\n=== COMPLIANCE & INSIGHTS ===`,
      `Home plan compliance: ${s.compliance.home_plan_pct}%, Diet plan: ${s.compliance.diet_plan_pct}%, Attendance: ${s.compliance.attendance_pct}%`,
      `Recent wins: ${(s.recent_wins ?? []).join('; ') || 'none'}`,
      `Recent issues: ${(s.recent_issues ?? []).join('; ') || 'none'}`,
      `AI recommendations: ${s.ai_insights?.recommendations?.join('; ') ?? 'none'}`,
      `Risk flags: ${s.ai_insights?.risk_flags?.join('; ') ?? 'none'}`,
    );
  }

  if (recentAttendance.length) {
    const present = recentAttendance.filter((a) => a.status === 'present').length;
    parts.push(`\nAttendance (last ${recentAttendance.length} sessions): ${present}/${recentAttendance.length} present`);
  }

  if (recentSessions.length) {
    parts.push('\n=== RECENT SESSIONS ===');
    recentSessions.forEach((sess, i) => {
      if (sess.notes) {
        const n = sess.notes;
        parts.push(
          `Session ${i + 1} (${sess.scheduled_at.toLocaleDateString()}): ` +
          `Attention ${n.attention_score}/10, Communication ${n.communication_score}/10, ` +
          `Behavior ${n.behavior_score}/10. Observations: ${n.observations ?? 'none'}. ` +
          `Follow-up: ${n.follow_up_required ? 'yes' : 'no'}.`,
        );
      }
    });
  }

  if (goals.length) {
    const active   = goals.filter((g) => g.status === 'active').map((g) => g.title);
    const proposed = goals.filter((g) => g.status === 'proposed').map((g) => g.title);
    const done     = goals.filter((g) => g.status === 'completed').map((g) => g.title);
    parts.push(`\n=== GOALS ===`);
    if (active.length)   parts.push(`Active: ${active.join('; ')}`);
    if (proposed.length) parts.push(`Proposed: ${proposed.join('; ')}`);
    if (done.length)     parts.push(`Completed: ${done.join('; ')}`);
  }

  if (alerts.length) {
    parts.push(`\n=== OPEN ALERTS ===`);
    alerts.forEach((a) => parts.push(`[${a.priority ?? 'normal'}] ${a.description}`));
  }

  if (concerns.length) {
    parts.push(`\n=== OPEN CONCERNS ===`);
    concerns.forEach((c) => parts.push(`[${c.category}] ${c.description}`));
  }

  if (activePlan) {
    parts.push(
      `\n=== ACTIVE HOME PLAN (${activePlan.start_date.toLocaleDateString()} – ${activePlan.end_date.toLocaleDateString()}) ===`,
      `Tasks: ${activePlan.tasks.map((t) => `${t.title} (${t.time_of_day}, ${t.duration_min}min, ${t.frequency})`).join('; ')}`,
    );
  }

  if (activeDietPlan) {
    parts.push(
      `\n=== ACTIVE DIET PLAN (${activeDietPlan.start_date.toLocaleDateString()} – ${activeDietPlan.end_date.toLocaleDateString()}) ===`,
      `Meals: ${activeDietPlan.meals.map((m) => `${m.name} (${m.meal_time}, ~${m.calories_approx}kcal)`).join('; ')}`,
    );
    if (activeDietPlan.notes) parts.push(`Notes: ${activeDietPlan.notes}`);
  }

  if (recentReviews.length) {
    parts.push(`\n=== RECENT REVIEWS ===`);
    recentReviews.forEach((r) => {
      parts.push(
        `${r.review_type} review (${r.period_start.toLocaleDateString()} – ${r.period_end.toLocaleDateString()}): ${r.text_observations}`,
      );
    });
  }

  return parts.join('\n');
}

async function logAiCall(params: {
  calledBy: string;
  childId:  string;
  endpoint: string;
  inputTokens: number;
  outputTokens: number;
  responseSummary: string;
}) {
  await AiCallModel.create({
    called_by:        params.calledBy,
    child_id:         params.childId,
    endpoint:         params.endpoint,
    model:            GEMINI_MODEL,
    input_tokens:     params.inputTokens,
    output_tokens:    params.outputTokens,
    redacted_request: {},
    response_summary: params.responseSummary.slice(0, 500),
    cost_usd:         (params.inputTokens * 0.00000015) + (params.outputTokens * 0.0000006),
  }).catch(() => { /* non-blocking */ });
}

export async function generateTherapyPlan(childId: string, user: AuthPayload) {
  if (!(AI_ROLES as readonly string[]).includes(user.role)) {
    throw new AppError('FORBIDDEN', 'Access denied');
  }

  const childContext = await buildChildContext(childId);
  const ragChunks    = await retrieveChunks('therapy_protocol', 4);
  const ragContext   = ragChunks.length ? `\nKnowledge base:\n${ragChunks.join('\n---\n')}` : '';

  const prompt = `You are an expert pediatric therapist creating a personalized therapy plan.

Child profile:
${childContext}
${ragContext}

Generate a structured 4-week therapy plan with:
1. Weekly goals (measurable)
2. Daily session activities (5-10 minutes each)
3. Home reinforcement tasks for parents
4. Progress indicators to track

Be specific, actionable, and evidence-based. Format clearly with sections.`;

  const { text, inputTokens, outputTokens } = await generateText(prompt);

  const draft = await AiDraftModel.create({
    child_id:     childId,
    generated_by: user.sub,
    type:         'therapy_plan' as AiDraftType,
    content:      text,
    model_used:   GEMINI_MODEL,
  });

  await logAiCall({
    calledBy:        user.sub,
    childId,
    endpoint:        '/ai/therapy-plan',
    inputTokens,
    outputTokens,
    responseSummary: text,
  });

  return draft;
}

export async function generateHomePlan(childId: string, user: AuthPayload) {
  if (!(AI_ROLES as readonly string[]).includes(user.role)) {
    throw new AppError('FORBIDDEN', 'Access denied');
  }

  const childContext = await buildChildContext(childId);
  const ragChunks    = await retrieveChunks('home_activity', 4);
  const ragContext   = ragChunks.length ? `\nKnowledge base:\n${ragChunks.join('\n---\n')}` : '';

  const prompt = `You are an expert creating a home therapy support plan for parents.

Child profile:
${childContext}
${ragContext}

Generate a 2-week home plan with:
1. Morning routine activities (with exact times)
2. Evening reinforcement tasks
3. Weekend enrichment activities
4. Parent guidance notes for each activity
5. What to observe and report

Make it practical for busy parents. Each activity should take 5-15 minutes.`;

  const { text, inputTokens, outputTokens } = await generateText(prompt);

  const draft = await AiDraftModel.create({
    child_id:     childId,
    generated_by: user.sub,
    type:         'home_plan' as AiDraftType,
    content:      text,
    model_used:   GEMINI_MODEL,
  });

  await logAiCall({
    calledBy:        user.sub,
    childId,
    endpoint:        '/ai/home-plan',
    inputTokens,
    outputTokens,
    responseSummary: text,
  });

  return draft;
}

export async function generateDietSummary(childId: string, user: AuthPayload) {
  if (!['dietician', 'center_head', 'therapist'].includes(user.role)) {
    throw new AppError('FORBIDDEN', 'Access denied');
  }

  const childContext = await buildChildContext(childId);
  const ragChunks    = await retrieveChunks('diet_guideline', 3);
  const ragContext   = ragChunks.length ? `\nGuidelines:\n${ragChunks.join('\n---\n')}` : '';

  const prompt = `You are a pediatric dietitian creating a diet summary for a child with special needs.

Child profile:
${childContext}
${ragContext}

Generate:
1. Nutritional assessment based on profile
2. Key dietary recommendations (avoid/include)
3. Sample weekly meal plan outline
4. Supplement considerations
5. Foods to avoid (if any allergies or sensitivities noted)

Keep recommendations practical and culturally sensitive.`;

  const { text, inputTokens, outputTokens } = await generateText(prompt);

  const draft = await AiDraftModel.create({
    child_id:     childId,
    generated_by: user.sub,
    type:         'diet_summary' as AiDraftType,
    content:      text,
    model_used:   GEMINI_MODEL,
  });

  await logAiCall({
    calledBy:        user.sub,
    childId,
    endpoint:        '/ai/diet-summary',
    inputTokens,
    outputTokens,
    responseSummary: text,
  });

  return draft;
}

export async function generateReinforcementActivities(childId: string, user: AuthPayload) {
  if (!(AI_ROLES as readonly string[]).includes(user.role)) {
    throw new AppError('FORBIDDEN', 'Access denied');
  }

  const childContext = await buildChildContext(childId);
  const ragChunks    = await retrieveChunks('behavior_strategy', 4);
  const ragContext   = ragChunks.length ? `\nStrategies:\n${ragChunks.join('\n---\n')}` : '';

  const prompt = `You are a behavioral therapist creating reinforcement activities.

Child profile:
${childContext}
${ragContext}

Generate 10 reinforcement activities:
- 4 for attention and focus
- 3 for social skills
- 3 for communication

For each: name, description, duration, materials needed, how to reinforce success.`;

  const { text, inputTokens, outputTokens } = await generateText(prompt);

  const draft = await AiDraftModel.create({
    child_id:     childId,
    generated_by: user.sub,
    type:         'reinforcement_activities' as AiDraftType,
    content:      text,
    model_used:   GEMINI_MODEL,
  });

  await logAiCall({
    calledBy:        user.sub,
    childId,
    endpoint:        '/ai/reinforcement-activities',
    inputTokens,
    outputTokens,
    responseSummary: text,
  });

  return draft;
}

export async function generateInsights(childId: string, user: AuthPayload) {
  if (!(AI_ROLES as readonly string[]).includes(user.role)) {
    throw new AppError('FORBIDDEN', 'Access denied');
  }

  const childContext = await buildChildContext(childId);

  const prompt = `You are a pediatric therapy supervisor analyzing a child's progress.

Child profile:
${childContext}

Provide a clinical progress analysis:
1. Overall progress assessment (strengths / areas of concern)
2. Risk flags (any regressions or missed targets)
3. Recommended adjustments to current therapy plan
4. Parent communication points
5. Short-term priorities for next 4 weeks

Be clinical but clear. Use bullet points.`;

  const { text, inputTokens, outputTokens } = await generateText(prompt);

  const draft = await AiDraftModel.create({
    child_id:     childId,
    generated_by: user.sub,
    type:         'insights' as AiDraftType,
    content:      text,
    model_used:   GEMINI_MODEL,
  });

  await logAiCall({
    calledBy:        user.sub,
    childId,
    endpoint:        '/ai/insights',
    inputTokens,
    outputTokens,
    responseSummary: text,
  });

  return draft;
}

export async function approveDraft(draftId: string, user: AuthPayload) {
  if (!['therapist', 'center_head', 'dietician'].includes(user.role)) {
    throw new AppError('FORBIDDEN', 'Access denied');
  }
  const draft = await AiDraftModel.findByIdAndUpdate(
    draftId,
    { $set: { status: 'approved', approved_by: user.sub, approved_at: new Date() } },
    { new: true },
  );
  if (!draft) throw new AppError('NOT_FOUND', 'Draft not found');

  const childId = draft.child_id.toString();
  const now     = new Date();
  const twoWeeks = new Date(now.getTime() + 14 * 24 * 60 * 60 * 1000);

  if (draft.type === 'home_plan') {
    await HomePlanModel.updateMany({ child_id: childId, is_active: true }, { $set: { is_active: false } });
    await HomePlanModel.create({
      child_id:      childId,
      therapist_id:  user.sub,
      start_date:    now,
      end_date:      twoWeeks,
      tasks: [{
        task_id:      'ai-generated',
        title:        'AI-Generated Home Plan',
        description:  draft.content.slice(0, 500),
        icon:         '🤖',
        time_of_day:  'morning',
        duration_min: 15,
        frequency:    'daily',
        target_count: 1,
      }],
      ai_draft_diff: { draft_id: draftId, full_content: draft.content },
      is_active:     true,
    });
  }

  if (draft.type === 'diet_summary') {
    await DietPlanModel.updateMany({ child_id: childId, is_active: true }, { $set: { is_active: false } });
    await DietPlanModel.create({
      child_id:     childId,
      therapist_id: user.sub,
      start_date:   now,
      end_date:     twoWeeks,
      meals: [{
        meal_id:         'ai-generated',
        name:            'AI-Generated Diet Plan',
        description:     draft.content.slice(0, 500),
        meal_time:       'breakfast',
        calories_approx: 0,
        ingredients:     [],
        frequency:       'daily',
      }],
      notes:    draft.content,
      is_active: true,
    });
  }

  return draft;
}

export async function listDrafts(childId: string, user: AuthPayload) {
  if (!(AI_ROLES as readonly string[]).includes(user.role)) {
    throw new AppError('FORBIDDEN', 'Access denied');
  }
  return AiDraftModel.find({ child_id: childId })
    .sort({ created_at: -1 })
    .limit(20)
    .lean();
}

// Keep backward-compatible stubs for old routes
export async function generatePlan(childId: string, therapyType: string, user: AuthPayload) {
  return generateTherapyPlan(childId, user);
}

export async function approvePlan(draftId: string, user: AuthPayload) {
  return approveDraft(draftId, user);
}

export async function getInsights(childId: string, user: AuthPayload) {
  return generateInsights(childId, user);
}
