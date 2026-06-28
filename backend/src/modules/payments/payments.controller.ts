import * as PaymentsService from './payments.service';
import { asyncHandler }     from '../../utils/http';
import { AppError }         from '../../middleware/error';

export const createPayment = asyncHandler(async (req, res) => {
  const { parent_id, child_id, session_id, type, amount_paise, notes } =
    req.body as { parent_id?: string; child_id?: string; session_id?: string; type?: string; amount_paise?: number; notes?: string };
  if (!type)         throw new AppError('INVALID_INPUT', 'type is required');
  if (!amount_paise) throw new AppError('INVALID_INPUT', 'amount_paise is required');
  const payment = await PaymentsService.createPayment(
    { parent_id, child_id, session_id, type, amount_paise, notes },
    req.user!,
  );
  res.status(201).json(payment);
});

export const listPayments = asyncHandler(async (req, res) => {
  const { child_id } = req.query;
  const payments = await PaymentsService.listPayments(
    req.user!,
    typeof child_id === 'string' ? child_id : undefined,
  );
  res.json(payments);
});

export const updatePaymentStatus = asyncHandler(async (req, res) => {
  const { status, razorpay_payment_id } = req.body as { status?: string; razorpay_payment_id?: string };
  if (!status) throw new AppError('INVALID_INPUT', 'status is required');
  const payment = await PaymentsService.updatePaymentStatus(
    req.params.id,
    status,
    razorpay_payment_id,
    req.user!,
  );
  res.json(payment);
});

export const getPaymentSummary = asyncHandler(async (req, res) => {
  const summary = await PaymentsService.getPaymentSummary(req.user!);
  res.json(summary);
});
