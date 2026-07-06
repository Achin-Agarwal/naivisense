import { VideoModel }              from '../../models/video.model';
import { ChildModel }              from '../../models/child.model';
import { AppError }                from '../../middleware/error';
import { uploadToCloudinaryFull }  from '../../config/cloudinary';
import type { AuthPayload }        from '../../middleware/auth';
import type { CreateVideoInput, UpdateVideoInput } from './videos.schema';

const UPLOAD_ROLES = ['parent', 'therapist', 'clinical_psychologist', 'center_head'] as const;
const ASSIGN_ROLES = ['therapist', 'clinical_psychologist'] as const;

async function assertCanAccessChild(user: AuthPayload, childId: string) {
  const child = await ChildModel.findById(childId).lean();
  if (!child) throw new AppError('NOT_FOUND', 'Child not found');

  const canAccess =
    user.role === 'center_head' ||
    user.role === 'clinical_psychologist' ||
    (user.role === 'therapist' && (child.therapists ?? []).some((t) => String(t.therapist_id) === user.sub)) ||
    (user.role === 'parent'    && String(child.parent_id) === user.sub);

  if (!canAccess) throw new AppError('FORBIDDEN', 'Access denied for this child');
}

export async function createVideo(input: CreateVideoInput, file: Express.Multer.File, user: AuthPayload) {
  if (!(UPLOAD_ROLES as readonly string[]).includes(user.role)) {
    throw new AppError('FORBIDDEN', 'You are not allowed to upload videos');
  }

  if (input.child_id) {
    await assertCanAccessChild(user, input.child_id);
  }

  const publicId = `naivisense/videos/${user.sub}/${Date.now()}`;
  const { url, public_id } = await uploadToCloudinaryFull(file.buffer, 'naivisense/videos', publicId, file.mimetype);

  return VideoModel.create({
    ...input,
    uploaded_by:          user.sub,
    uploaded_by_role:     user.role as typeof UPLOAD_ROLES[number],
    url,
    cloudinary_public_id: public_id,
  });
}

export async function listVideos(childId: string, category: string | undefined, user: AuthPayload) {
  await assertCanAccessChild(user, childId);

  const filter: Record<string, unknown> = {
    $or: [{ child_id: childId }, { assigned_children: childId }],
  };
  if (user.role === 'parent') filter.visibility = 'parent_visible';
  if (category) filter.category = category;

  return VideoModel.find(filter).sort({ created_at: -1 }).lean();
}

export async function getVideo(id: string, user: AuthPayload) {
  const video = await VideoModel.findById(id).lean();
  if (!video) throw new AppError('NOT_FOUND', 'Video not found');
  return video;
}

export async function updateVideo(id: string, updates: UpdateVideoInput, user: AuthPayload) {
  const video = await VideoModel.findById(id).lean();
  if (!video) throw new AppError('NOT_FOUND', 'Video not found');

  const canEdit = user.role === 'center_head' || String(video.uploaded_by) === user.sub;
  if (!canEdit) throw new AppError('FORBIDDEN', 'Only the uploader or center head can update this video');

  return VideoModel.findByIdAndUpdate(id, { $set: updates }, { new: true });
}

export async function deleteVideo(id: string, user: AuthPayload) {
  const video = await VideoModel.findById(id).lean();
  if (!video) throw new AppError('NOT_FOUND', 'Video not found');

  const canDelete = user.role === 'center_head' || String(video.uploaded_by) === user.sub;
  if (!canDelete) throw new AppError('FORBIDDEN', 'Only the uploader or center head can delete this video');

  await VideoModel.findByIdAndDelete(id);
}

export async function assignVideo(videoId: string, childId: string, user: AuthPayload) {
  if (!(ASSIGN_ROLES as readonly string[]).includes(user.role)) {
    throw new AppError('FORBIDDEN', 'You are not allowed to assign videos');
  }

  const video = await VideoModel.findById(videoId);
  if (!video) throw new AppError('NOT_FOUND', 'Video not found');

  // A video that already belongs to a specific child (child_id set) was
  // uploaded for that child only — it must never be assignable to a
  // different child, since that would leak one family's video to another.
  if (video.child_id) {
    throw new AppError('FORBIDDEN', 'This video already belongs to a specific child and cannot be assigned to others');
  }

  await assertCanAccessChild(user, childId);

  const alreadyAssigned = video.assigned_children.some((id) => String(id) === childId);
  if (!alreadyAssigned) {
    video.assigned_children.push(childId as any);
    await video.save();
  }

  return video;
}

export async function deassignVideo(videoId: string, childId: string, user: AuthPayload) {
  if (!(ASSIGN_ROLES as readonly string[]).includes(user.role)) {
    throw new AppError('FORBIDDEN', 'You are not allowed to deassign videos');
  }

  const video = await VideoModel.findById(videoId);
  if (!video) throw new AppError('NOT_FOUND', 'Video not found');

  video.assigned_children = video.assigned_children.filter((id) => String(id) !== childId) as any;
  await video.save();

  return video;
}