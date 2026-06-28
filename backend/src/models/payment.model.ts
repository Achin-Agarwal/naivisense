import mongoose, { Schema, Document } from 'mongoose';

export type PaymentStatus = 'pending' | 'paid' | 'failed' | 'refunded';
export type PaymentType   = 'session_fee' | 'subscription' | 'assessment_fee' | 'other';

export interface IPayment extends Document {
  parent_id:       string;
  child_id?:       string;
  session_id?:     string;
  type:            PaymentType;
  amount_paise:    number;
  currency:        string;
  status:          PaymentStatus;
  razorpay_order_id?:   string;
  razorpay_payment_id?: string;
  notes?:          string;
  paid_at?:        Date;
  created_at:      Date;
  updated_at:      Date;
}

const PaymentSchema = new Schema<IPayment>({
  parent_id:            { type: String, required: true },
  child_id:             { type: String },
  session_id:           { type: String },
  type:                 { type: String, enum: ['session_fee', 'subscription', 'assessment_fee', 'other'], required: true },
  amount_paise:         { type: Number, required: true },
  currency:             { type: String, default: 'INR' },
  status:               { type: String, enum: ['pending', 'paid', 'failed', 'refunded'], default: 'pending' },
  razorpay_order_id:    { type: String },
  razorpay_payment_id:  { type: String },
  notes:                { type: String },
  paid_at:              { type: Date },
}, { timestamps: { createdAt: 'created_at', updatedAt: 'updated_at' } });

PaymentSchema.index({ parent_id: 1, created_at: -1 });
PaymentSchema.index({ status: 1 });

export const PaymentModel = mongoose.model<IPayment>('Payment', PaymentSchema);
