import { z }                      from 'zod';
import * as UsersService           from './users.service';
import { uploadToCloudinary }      from '../../config/cloudinary';
import { asyncHandler }            from '../../utils/http';
import { AppError }                from '../../middleware/error';
import { EnrollTherapistSchema }   from './users.therapist-schema';
import { EnrollParentSchema }      from './users.parent-schema';
import { EnrollStaffSchema }       from './users.staff-schema';
import { ALL_ROLES }               from '../../models/user.model';

const UpdateMeSchema = z.object({
  name: z.string().min(2).max(100).trim().optional(),
});

export const getMe = asyncHandler(async (req, res) => {
  const user = await UsersService.getMe(req.user!);
  res.json(user);
});

export const updateMe = asyncHandler(async (req, res) => {
  const { name } = UpdateMeSchema.parse(req.body);
  const user     = await UsersService.updateMe(req.user!, { name });
  res.json(user);
});

export const getTherapistsOverview = asyncHandler(async (req, res) => {
  const data = await UsersService.getTherapistsOverview(req.user!);
  res.json(data);
});

export const enrollTherapist = asyncHandler(async (req, res) => {
  const input = EnrollTherapistSchema.parse(req.body);
  const result = await UsersService.enrollTherapist(input, req.user!);
  res.status(201).json(result);
});

export const enrollParent = asyncHandler(async (req, res) => {
  const input = EnrollParentSchema.parse(req.body);
  const result = await UsersService.enrollParent(input, req.user!);
  res.status(201).json(result);
});

export const uploadTherapistDocument = asyncHandler(async (req, res) => {
  if (!req.file) throw new AppError('INVALID_INPUT', 'No file provided');
  const docType = req.params.docType as 'photo' | 'degree' | 'identity';
  if (!['photo', 'degree', 'identity'].includes(docType)) {
    throw new AppError('INVALID_INPUT', 'docType must be photo, degree, or identity');
  }
  const result = await UsersService.uploadTherapistDocument(
    req.params.id,
    docType,
    req.file.buffer,
    req.file.mimetype,
    req.user!,
  );
  res.json(result);
});

export const enrollStaff = asyncHandler(async (req, res) => {
  const input  = EnrollStaffSchema.parse(req.body);
  const result = await UsersService.enrollStaff(input, req.user!);
  res.status(201).json(result);
});

export const listStaff = asyncHandler(async (req, res) => {
  const role = (req.query.role as string) ?? 'therapist';
  if (!ALL_ROLES.includes(role as typeof ALL_ROLES[number])) {
    throw new AppError('INVALID_INPUT', `role must be one of: ${ALL_ROLES.join(', ')}`);
  }
  const users = await UsersService.listByRole(role, req.user!);
  res.json(users);
});

export const getUser = asyncHandler(async (req, res) => {
  const user = await UsersService.getById(req.params.id, req.user!);
  res.json(user);
});

export const uploadPhoto = asyncHandler(async (req, res) => {
  if (!req.file) throw new AppError('INVALID_INPUT', 'No image file provided');
  const photo_url = await uploadToCloudinary(
    req.file.buffer,
    'users',
    `${req.user!.sub}/photo_${Date.now()}`,
    req.file.mimetype,
  );
  const user      = await UsersService.updateMe(req.user!, { photo_url });
  res.json(user);
});
