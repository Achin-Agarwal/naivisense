import mongoose, { Schema, Document } from 'mongoose';

export type ReviewType   = 'monthly' | 'quarterly';
export type ReviewStatus = 'draft' | 'published';

export interface IReview extends Document {
  child_id:          mongoose.Types.ObjectId;
  review_type:       ReviewType;
  created_by:        mongoose.Types.ObjectId;
  period_start:      Date;
  period_end:        Date;
  text_observations: string;
  admin_notes?:      string;
  video_ids:         mongoose.Types.ObjectId[];
  assessment_id?:    mongoose.Types.ObjectId;
  status:            ReviewStatus;
  created_at:        Date;
  updated_at:        Date;
}

const reviewSchema = new Schema<IReview>(
  {
    child_id:          { type: Schema.Types.ObjectId, ref: 'Child',      required: true },
    review_type:       { type: String, enum: ['monthly', 'quarterly'],    required: true },
    created_by:        { type: Schema.Types.ObjectId, ref: 'User',        required: true },
    period_start:      { type: Date, required: true },
    period_end:        { type: Date, required: true },
    text_observations: { type: String, required: true },
    admin_notes:       { type: String },
    video_ids:         [{ type: Schema.Types.ObjectId, ref: 'Video' }],
    assessment_id:     { type: Schema.Types.ObjectId, ref: 'Assessment' },
    status:            { type: String, enum: ['draft', 'published'], default: 'draft' },
  },
  { timestamps: { createdAt: 'created_at', updatedAt: 'updated_at' } },
);

reviewSchema.index({ child_id: 1, review_type: 1 });
reviewSchema.index({ child_id: 1, status: 1 });

export const ReviewModel = mongoose.model<IReview>('Review', reviewSchema);
