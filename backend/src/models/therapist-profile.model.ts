import mongoose, { Schema, Document } from 'mongoose';

export interface ITherapistProfile extends Document {
  user_id:                  mongoose.Types.ObjectId;
  dob?:                     Date;
  gender?:                  'male' | 'female' | 'other';
  qualification:            string;
  certifications:           string[];
  years_experience:         number;
  workplace_type:           'clinic' | 'hospital' | 'freelance' | 'ngo';
  organization_name?:       string;
  license_number?:          string;
  age_groups:               string[];
  conditions_handled:       string[];
  therapy_methods:          string[];
  available_days:           string[];
  session_modes:            string[];
  session_duration:         number;
  degree_certificate_url?:  string;
  identity_proof_url?:      string;
  identity_proof_type?:     'aadhar' | 'pan' | 'passport' | 'driving_license';
  mail_credentials?: {
    smtp_email: string;
    encrypted_password: string;
    provider: 'gmail' | 'outlook';
};
}

const therapistProfileSchema = new Schema<ITherapistProfile>({
  user_id:                  { type: Schema.Types.ObjectId, ref: 'User', required: true, unique: true },
  dob:                      { type: Date },
  gender:                   { type: String, enum: ['male', 'female', 'other'] },
  qualification:            { type: String, default: '' },
  certifications:           [{ type: String }],
  years_experience:         { type: Number, default: 0 },
  workplace_type:           { type: String, enum: ['clinic', 'hospital', 'freelance', 'ngo'], default: 'clinic' },
  organization_name:        { type: String },
  license_number:           { type: String },
  age_groups:               [{ type: String }],
  conditions_handled:       [{ type: String }],
  therapy_methods:          [{ type: String }],
  available_days:           [{ type: String }],
  session_modes:            [{ type: String }],
  session_duration:         { type: Number, default: 45 },
  degree_certificate_url:   { type: String },
  identity_proof_url:       { type: String },
  identity_proof_type:      { type: String, enum: ['aadhar', 'pan', 'passport', 'driving_license'] },
  mail_credentials: {
  smtp_email: {
    type: String,
  },

  encrypted_password: {
    type: String,
  },

  provider: {
    type: String,
    enum: ['gmail', 'outlook'],
    default: 'gmail',
  },
},
});

export const TherapistProfileModel = mongoose.model<ITherapistProfile>(
  'TherapistProfile',
  therapistProfileSchema,
);
