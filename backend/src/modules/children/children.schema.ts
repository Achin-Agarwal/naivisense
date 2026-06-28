import { z } from 'zod';

export const CreateChildSchema = z.object({
  name:             z.string().min(1).max(100).trim(),
  nickname:         z.string().optional(),
  dob:              z.string().datetime({ offset: true }),
  gender:           z.enum(['boy', 'girl', 'other']),
  diagnosis:        z.array(z.string()).min(1),
  severity:         z.enum(['mild', 'moderate', 'severe']),
  primary_concerns: z.array(z.string()).default([]),
  therapy_targets:  z.array(z.string()).min(1),
  parent_id:        z.string().length(24),
  enrollment_mode:  z.enum(['online', 'offline', 'hybrid']).default('offline'),
  parent_email:     z.string().email().optional(),
  therapists: z.array(z.object({
    therapist_id: z.string().length(24),
    therapy_type: z.string().min(1),
    schedule: z.object({
      days:      z.array(z.number().int().min(0).max(6)),
      from_time: z.string().regex(/^\d{2}:\d{2}$/),
      to_time:   z.string().regex(/^\d{2}:\d{2}$/),
    }).optional(),
  })).optional().default([]),
  medical: z.object({
    birth_history:       z.enum(['normal', 'premature', 'complications']).default('normal'),
    milestones_delay:    z.boolean().default(false),
    hearing_issues:      z.boolean().default(false),
    vision_issues:       z.boolean().default(false),
    current_medications: z.array(z.string()).default([]),
  }).optional(),
  emergency_contact: z.object({
    name:  z.string(),
    phone: z.string(),
  }).optional(),
  home_context: z.object({
    primary_caregiver:  z.string().optional(),
    screen_time_hours:  z.number().min(0).max(24).default(0),
    play_type:          z.enum(['alone', 'guided', 'group']).default('guided'),
    parent_involvement: z.enum(['low', 'medium', 'high']).default('medium'),
  }).optional(),
  goals: z.object({
    priorities:      z.array(z.string()).optional(),
    timeline_months: z.number().default(6),
  }).optional(),
  consent_record: z.object({
    given_at: z.string().datetime({ offset: true }),
    given_by: z.string(),
  }),
  functional_baseline: z.object({
    communication_level: z.enum(['non_verbal', 'single_words', 'phrases', 'sentences']).default('non_verbal'),
    attention_span_mins: z.number().min(0).max(120).default(5),
    social_interaction:  z.enum(['avoids', 'parallel', 'interactive']).default('avoids'),
    motor_skills:        z.enum(['low', 'medium', 'age_appropriate']).default('low'),
    behavior_pattern:    z.enum(['calm', 'challenging', 'mixed']).default('mixed'),
  }).optional(),
  previous_therapy: z.object({
    had_therapy:     z.boolean().default(false),
    types:           z.array(z.string()).default([]),
    duration_months: z.number().min(0).default(0),
    progress_noted:  z.string().default(''),
  }).optional(),
});

export type CreateChildInput = z.infer<typeof CreateChildSchema>;
