import { NotificationModel } from '../../models/notification.model';
import { AppError }          from '../../middleware/error';
import type { AuthPayload }  from '../../middleware/auth';
import type { CreateNotificationInput } from './notifications.schema';

export async function createNotification(input: CreateNotificationInput, user: AuthPayload) {
  if (user.role !== 'center_head') {
    throw new AppError('FORBIDDEN', 'Only center head can create notifications');
  }
  return NotificationModel.create(input);
}

export async function listNotifications(user: AuthPayload) {
  return NotificationModel.find({ user_id: user.sub })
    .sort({ created_at: -1 })
    .limit(50)
    .lean();
}

export async function markRead(id: string, user: AuthPayload) {
  const notification = await NotificationModel.findById(id);
  if (!notification) throw new AppError('NOT_FOUND', 'Notification not found');
  if (String(notification.user_id) !== user.sub) {
    throw new AppError('FORBIDDEN', 'Access denied');
  }
  notification.read = true;
  return notification.save();
}

// Helper used by other modules to push in-app notifications
export async function push(
  userId: string,
  type:   CreateNotificationInput['type'],
  title:  string,
  body:   string,
  data?:  Record<string, unknown>,
) {
  return NotificationModel.create({ user_id: userId, type, title, body, data });
}
