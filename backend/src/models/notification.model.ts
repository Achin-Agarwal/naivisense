import mongoose, { Schema, Document } from 'mongoose';

export type NotificationType = 'session_reminder' | 'alert_raised' | 'plan_updated' | 'review_published' | 'general';

export interface INotification extends Document {
  user_id:     mongoose.Types.ObjectId;
  type:        NotificationType;
  title:       string;
  body:        string;
  read:        boolean;
  data?:       Record<string, unknown>;
  created_at:  Date;
  updated_at:  Date;
}

const notificationSchema = new Schema<INotification>(
  {
    user_id: { type: Schema.Types.ObjectId, ref: 'User', required: true },
    type:    { type: String, enum: ['session_reminder', 'alert_raised', 'plan_updated', 'review_published', 'general'], required: true },
    title:   { type: String, required: true },
    body:    { type: String, required: true },
    read:    { type: Boolean, default: false },
    data:    { type: Schema.Types.Mixed },
  },
  { timestamps: { createdAt: 'created_at', updatedAt: 'updated_at' } },
);

notificationSchema.index({ user_id: 1, read: 1 });
notificationSchema.index({ user_id: 1, created_at: -1 });

export const NotificationModel = mongoose.model<INotification>('Notification', notificationSchema);
