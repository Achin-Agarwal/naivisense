import * as NotificationsService from './notifications.service';
import { CreateNotificationSchema } from './notifications.schema';
import { asyncHandler } from '../../utils/http';

export const create = asyncHandler(async (req, res) => {
  const input        = CreateNotificationSchema.parse(req.body);
  const notification = await NotificationsService.createNotification(input, req.user!);
  res.status(201).json(notification);
});

export const list = asyncHandler(async (req, res) => {
  const notifications = await NotificationsService.listNotifications(req.user!);
  res.json(notifications);
});

export const markRead = asyncHandler(async (req, res) => {
  const notification = await NotificationsService.markRead(req.params.id, req.user!);
  res.json(notification);
});
