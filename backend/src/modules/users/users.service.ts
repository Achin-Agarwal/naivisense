import bcrypt                    from 'bcrypt';
import { UserModel }             from '../../models/user.model';
import { TherapistProfileModel } from '../../models/therapist-profile.model';
import { CenterProfileModel }    from '../../models/center-profile.model';
import { ChildModel }            from '../../models/child.model';
import { AppError }              from '../../middleware/error';
import { uploadToCloudinary }    from '../../config/cloudinary';
import type { AuthPayload }      from '../../middleware/auth';
import type { EnrollTherapistInput } from './users.therapist-schema';
import type { EnrollCenterHeadInput } from './users.center-head-schema';
import type { EnrollParentInput }    from './users.parent-schema';
import type { EnrollStaffInput }     from './users.staff-schema';
import { encrypt } from '../../utils/crypto';

export async function getMe(user: AuthPayload) {
  const doc = await UserModel.findById(user.sub).lean();
  if (!doc) throw new AppError('NOT_FOUND', 'User not found');
  return doc;
}

export async function listByRole(role: string, caller: AuthPayload) {
  if (caller.role !== 'center_head') throw new AppError('FORBIDDEN', 'Access denied');
  return UserModel.find({ role }, { password_hash: 0 }).sort({ name: 1 }).lean();
}

export async function getById(id: string, caller: AuthPayload) {
  if (caller.role !== 'center_head') throw new AppError('FORBIDDEN', 'Access denied');
  const doc = await UserModel.findById(id, { password_hash: 0 }).lean();
  if (!doc) throw new AppError('NOT_FOUND', 'User not found');
  return doc;
}

export async function getTherapistsOverview(caller: AuthPayload) {
  if (caller.role !== 'center_head') throw new AppError('FORBIDDEN', 'Access denied');

  const therapists = await UserModel.find({ role: 'therapist' }, { password_hash: 0 })
    .sort({ name: 1 })
    .lean();

  const therapistIds = therapists.map((t) => t._id);

  const [profiles, children] = await Promise.all([
    TherapistProfileModel.find({ user_id: { $in: therapistIds } }).lean(),
    ChildModel.find({ 'therapists.therapist_id': { $in: therapistIds } }, {
      name: 1, diagnosis: 1, severity: 1, therapists: 1,
    }).lean(),
  ]);

  const profileMap = new Map(profiles.map((p) => [String(p.user_id), p]));

  // A child may have multiple therapists — add it to each one's list with its specific therapy_type
  const childrenByTherapist = new Map<string, { _id: string; name: string; diagnosis: string[]; severity: string; therapy_type: string }[]>();
  for (const child of children) {
    for (const assignment of child.therapists ?? []) {
      const tid = String(assignment.therapist_id);
      if (!childrenByTherapist.has(tid)) childrenByTherapist.set(tid, []);
      childrenByTherapist.get(tid)!.push({
        _id:          String(child._id),
        name:         child.name,
        diagnosis:    child.diagnosis,
        severity:     child.severity ?? '',
        therapy_type: assignment.therapy_type,
      });
    }
  }

  return therapists.map((t) => {
    const id      = String(t._id);
    const profile = profileMap.get(id);
    return {
      _id:              id,
      name:             t.name,
      phone:            t.phone,
      specialties:      profile?.conditions_handled ?? [],
      therapy_methods:  profile?.therapy_methods    ?? [],
      qualification:    profile?.qualification      ?? '',
      years_experience: profile?.years_experience   ?? 0,
      children:         childrenByTherapist.get(id) ?? [],
    };
  });
}

export async function enrollTherapist(input: EnrollTherapistInput, caller: AuthPayload) {
  if (caller.role !== 'center_head') throw new AppError('FORBIDDEN', 'Access denied');

  const existing = await UserModel.findOne({ phone: input.phone });
  if (existing) throw new AppError('CONFLICT', 'Phone number already registered');

  const hash = await bcrypt.hash(input.password, 12);
  const user = await UserModel.create({
    name:          input.name,
    phone:         input.phone,
    email:         input.email,
    password_hash: hash,
    role:          'therapist',
    is_verified:   true,
    
  });


  const profile = await TherapistProfileModel.create({
    user_id:          user._id,
    dob:              input.dob ? new Date(input.dob) : undefined,
    gender:           input.gender,
    qualification:    input.qualification ?? '',
    license_number:   input.license_number,
    years_experience: input.years_experience ?? 0,
    certifications:   input.certifications ?? [],
    workplace_type:   input.workplace_type ?? 'clinic',
    organization_name: input.organization_name,
    conditions_handled: input.conditions_handled ?? [],
    therapy_methods:  input.therapy_methods ?? [],
    age_groups:       input.age_groups ?? [],
    available_days:   input.available_days ?? [],
    session_modes:    input.session_modes ?? [],
    session_duration: input.session_duration ?? 45,
    identity_proof_type: input.identity_proof_type,
    
  });

  return { user, profile };
}

export async function uploadTherapistDocument(
  therapistId: string,
  docType: 'photo' | 'degree' | 'identity',
  buffer: Buffer,
  mimetype: string,
  caller: AuthPayload,
) {
  if (caller.role !== 'center_head') throw new AppError('FORBIDDEN', 'Access denied');

  const therapist = await UserModel.findById(therapistId);
  if (!therapist || therapist.role !== 'therapist')
    throw new AppError('NOT_FOUND', 'Therapist not found');

  const url = await uploadToCloudinary(
    buffer,
    'therapists',
    `${therapistId}/${docType}_${Date.now()}`,
    mimetype,
  );

  if (docType === 'photo') {
    await UserModel.findByIdAndUpdate(therapistId, { photo_url: url });
  } else {
    const field = docType === 'degree' ? 'degree_certificate_url' : 'identity_proof_url';
    await TherapistProfileModel.findOneAndUpdate({ user_id: therapistId }, { [field]: url });
  }

  return { url };
}

export async function enrollParent(input: EnrollParentInput, caller: AuthPayload) {
  if (caller.role !== 'center_head') throw new AppError('FORBIDDEN', 'Access denied');

  const existing = await UserModel.findOne({ phone: input.phone });
  if (existing) throw new AppError('CONFLICT', 'Phone number already registered');

  const hash = await bcrypt.hash(input.password, 12);
  const user = await UserModel.create({
    name:          input.name,
    phone:         input.phone,
    email:         input.email,
    password_hash: hash,
    role:          'parent',
    is_verified:   true,
  });

  return { user };
}

export async function enrollStaff(input: EnrollStaffInput, caller: AuthPayload) {
  if (caller.role !== 'center_head') throw new AppError('FORBIDDEN', 'Access denied');

  const existing = await UserModel.findOne({ phone: input.phone });
  if (existing) throw new AppError('CONFLICT', 'Phone number already registered');

  const hash = await bcrypt.hash(input.password, 12);
  const user = await UserModel.create({
    name:          input.name,
    phone:         input.phone,
    email:         input.email,
    password_hash: hash,
    role:          input.role,
    is_verified:   true,
  });

  return { user };
}

export async function updateMe(user: AuthPayload, updates: { name?: string; photo_url?: string }) {
  const doc = await UserModel.findByIdAndUpdate(
    user.sub,
    { $set: updates },
    { new: true, runValidators: true },
  );
  if (!doc) throw new AppError('NOT_FOUND', 'User not found');
  return doc;
}


export async function enrollCenterHead(input: EnrollCenterHeadInput) {
  const existing = await UserModel.findOne({ phone: input.phone });

  if (existing) {
    throw new AppError("CONFLICT", "Phone number already registered");
  }

  const hash = await bcrypt.hash(input.password, 12);

  const user = await UserModel.create({
    name: input.name,
    phone: input.phone,
    email: input.email,
    password_hash: hash,
    role: "center_head",
    is_verified: true,
  });

  const encryptedPassword = encrypt(
    input.smtp_credentials.smtp_password
  );

  const profile = await CenterProfileModel.create({
    user_id: user._id,

    center_name: input.center_name,

    smtp_host: input.smtp_credentials.smtp_host,

    smtp_port: input.smtp_credentials.smtp_port,

    smtp_secure: input.smtp_credentials.smtp_secure,

    smtp_user: input.smtp_credentials.smtp_user,

    smtp_password: encryptedPassword,
  });

  return { user, profile };
}

