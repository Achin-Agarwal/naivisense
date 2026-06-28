import { PaymentModel } from '../../models/payment.model';
import { AppError }     from '../../middleware/error';
import type { AuthPayload } from '../../middleware/auth';

export async function createPayment(data: {
  parent_id?:   string;
  child_id?:    string;
  session_id?:  string;
  type:         string;
  amount_paise: number;
  notes?:       string;
}, user: AuthPayload) {
  if (user.role !== 'center_head') {
    throw new AppError('FORBIDDEN', 'Only center_head can create payment records');
  }
  const resolvedParentId = data.parent_id ?? data.child_id ?? user.sub;
  const payment = await PaymentModel.create({
    parent_id:    resolvedParentId,
    child_id:     data.child_id,
    session_id:   data.session_id,
    type:         data.type,
    amount_paise: data.amount_paise,
    notes:        data.notes,
    status:       'pending',
  });
  return payment;
}

export async function listPayments(user: AuthPayload, childId?: string) {
  const staffRoles = ['center_head', 'therapist', 'lead_therapist'];
  if (!staffRoles.includes(user.role) && user.role !== 'parent') {
    throw new AppError('FORBIDDEN', 'Access denied');
  }

  const filter: Record<string, unknown> = {};
  if (user.role === 'parent') {
    filter['parent_id'] = user.sub;
  }
  if (childId) filter['child_id'] = childId;

  return PaymentModel.find(filter).sort({ created_at: -1 }).limit(50).lean();
}

export async function updatePaymentStatus(paymentId: string, status: string, razorpayPaymentId: string | undefined, user: AuthPayload) {
  if (user.role !== 'center_head') {
    throw new AppError('FORBIDDEN', 'Only center_head can update payment status');
  }
  const update: Record<string, unknown> = { status };
  if (razorpayPaymentId) update['razorpay_payment_id'] = razorpayPaymentId;
  if (status === 'paid') update['paid_at'] = new Date();

  const payment = await PaymentModel.findByIdAndUpdate(
    paymentId,
    { $set: update },
    { new: true },
  );
  if (!payment) throw new AppError('NOT_FOUND', 'Payment not found');
  return payment;
}

export async function getPaymentSummary(user: AuthPayload) {
  if (user.role !== 'center_head') throw new AppError('FORBIDDEN', 'Access denied');
  const [total, pending, paid] = await Promise.all([
    PaymentModel.countDocuments(),
    PaymentModel.countDocuments({ status: 'pending' }),
    PaymentModel.aggregate([
      { $match: { status: 'paid' } },
      { $group: { _id: null, total_paise: { $sum: '$amount_paise' } } },
    ]),
  ]);
  return {
    total_payments: total,
    pending_payments: pending,
    total_collected_paise: paid[0]?.total_paise ?? 0,
  };
}
