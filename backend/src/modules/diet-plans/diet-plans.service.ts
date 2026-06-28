import { DietPlanModel }    from '../../models/diet-plan.model';
import { MealLogModel }     from '../../models/meal-log.model';
import { VerificationModel } from '../../models/verification.model';
import { ChildModel }        from '../../models/child.model';
import { AppError }          from '../../middleware/error';
import type { AuthPayload }  from '../../middleware/auth';
import type { CreateDietPlanInput } from './diet-plans.schema';

export async function createDietPlan(input: CreateDietPlanInput, user: AuthPayload) {
  if (user.role !== 'therapist' && user.role !== 'dietician' && user.role !== 'center_head') {
    throw new AppError('FORBIDDEN', 'Only therapists, dieticians, and center head can create diet plans');
  }
  return DietPlanModel.create({
    ...input,
    therapist_id: user.sub,
    start_date:   new Date(input.start_date),
    end_date:     new Date(input.end_date),
  });
}

export async function getActivePlan(childId: string, user: AuthPayload) {
  const child = await ChildModel.findById(childId).lean();
  if (!child) throw new AppError('NOT_FOUND', 'Child not found');

  const canAccess =
    user.role === 'center_head' ||
    user.role === 'dietician'   ||
    (user.role === 'therapist' && (child.therapists ?? []).some((t) => String(t.therapist_id) === user.sub)) ||
    (user.role === 'parent'    && String(child.parent_id)    === user.sub);

  if (!canAccess) throw new AppError('FORBIDDEN', 'Access denied');

  const plan = await DietPlanModel.findOne({ child_id: childId, is_active: true })
    .sort({ created_at: -1 })
    .lean();
  if (!plan) throw new AppError('NOT_FOUND', 'No active diet plan found');
  return plan;
}

export async function logMeal(planId: string, mealId: string, user: AuthPayload) {
  if (user.role !== 'parent') {
    throw new AppError('FORBIDDEN', 'Only parents can log meals');
  }
  const plan = await DietPlanModel.findById(planId).lean();
  if (!plan) throw new AppError('NOT_FOUND', 'Diet plan not found');

  const meal = plan.meals.find((m) => m.meal_id === mealId);
  if (!meal) throw new AppError('NOT_FOUND', 'Meal not found in this plan');

  const log = await MealLogModel.create({
    diet_plan_id: planId,
    meal_id:      mealId,
    child_id:     plan.child_id,
    logged_by:    user.sub,
  });

  const verification = await VerificationModel.create({
    log_id:   log._id,
    log_type: 'diet',
    child_id: plan.child_id,
  });

  await MealLogModel.findByIdAndUpdate(log._id, { verification_id: verification._id });

  return { log, verification };
}
