import { VideoModel }                from '../../models/video.model';
import { ChildModel }               from '../../models/child.model';
import { AppError }                 from '../../middleware/error';
import { uploadToCloudinaryFull }   from '../../config/cloudinary';
import type { AuthPayload }         from '../../middleware/auth';
import type { CreateVideoInput, UpdateVideoInput } from './videos.schema';

const UPLOAD_ROLES = ['parent', 'therapist', 'clinical_psychologist', 'center_head'] as const;

export async function createVideo(
  input: CreateVideoInput,
  file: Express.Multer.File,
  user: AuthPayload,
) {
  if (!(UPLOAD_ROLES as readonly string[]).includes(user.role)) {
    throw new AppError('FORBIDDEN', 'You are not allowed to upload videos');
  }

  const child = await ChildModel.findById(input.child_id).lean();
  if (!child) throw new AppError('NOT_FOUND', 'Child not found');

  const canAccess =
    user.role === 'center_head' ||
    user.role === 'clinical_psychologist' ||
    (user.role === 'therapist' && (child.therapists ?? []).some((t) => String(t.therapist_id) === user.sub)) ||
    (user.role === 'parent'    && String(child.parent_id) === user.sub);

  if (!canAccess) throw new AppError('FORBIDDEN', 'Access denied for this child');

  const publicId = `naivisense/videos/${input.child_id}/${Date.now()}`;
  const { url, public_id } = await uploadToCloudinaryFull(file.buffer, 'naivisense/videos', publicId, file.mimetype);

  return VideoModel.create({
    ...input,
    uploaded_by:          user.sub,
    uploaded_by_role:     user.role as typeof UPLOAD_ROLES[number],
    url,
    cloudinary_public_id: public_id,
  });
}

export async function listVideos(
  childId: string,
  category: string | undefined,
  user: AuthPayload,
) {
  const child = await ChildModel.findById(childId).lean();
  if (!child) throw new AppError('NOT_FOUND', 'Child not found');

  const canAccess =
    user.role === 'center_head' ||
    user.role === 'lead_therapist' ||
    user.role === 'clinical_psychologist' ||
    (user.role === 'therapist' && (child.therapists ?? []).some((t) => String(t.therapist_id) === user.sub)) ||
    (user.role === 'parent'    && String(child.parent_id) === user.sub);

  if (!canAccess) throw new AppError('FORBIDDEN', 'Access denied');

  const filter: Record<string, unknown> = { child_id: childId };

  if (user.role === 'parent') {
    filter.visibility = 'parent_visible';
  }

  if (category) filter.category = category;

  return VideoModel.find(filter).sort({ created_at: -1 }).lean();
}

export async function getVideo(id: string, user: AuthPayload) {
  const video = await VideoModel.findById(id).lean();
  if (!video) throw new AppError('NOT_FOUND', 'Video not found');

  const child = await ChildModel.findById(video.child_id).lean();
  if (!child) throw new AppError('NOT_FOUND', 'Child not found');

  const canAccess =
    user.role === 'center_head' ||
    user.role === 'lead_therapist' ||
    user.role === 'clinical_psychologist' ||
    (user.role === 'therapist' && (child.therapists ?? []).some((t) => String(t.therapist_id) === user.sub)) ||
    (user.role === 'parent'    && String(child.parent_id) === user.sub && video.visibility === 'parent_visible');

  if (!canAccess) throw new AppError('FORBIDDEN', 'Access denied');

  return video;
}

export async function updateVideo(id: string, updates: UpdateVideoInput, user: AuthPayload) {
  const video = await VideoModel.findById(id).lean();
  if (!video) throw new AppError('NOT_FOUND', 'Video not found');

  const canEdit =
    user.role === 'center_head' ||
    (user.role === video.uploaded_by_role && String(video.uploaded_by) === user.sub);

  if (!canEdit) throw new AppError('FORBIDDEN', 'Only the uploader or center head can update this video');

  const updated = await VideoModel.findByIdAndUpdate(id, { $set: updates }, { new: true });
  return updated;
}
