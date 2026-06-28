import { z } from 'zod';

export const AddDocumentSchema = z.object({
  title:    z.string().min(1).max(300).trim(),
  category: z.enum(['therapy_protocol', 'diet_guideline', 'assessment_rubric', 'behavior_strategy', 'home_activity', 'general']),
  content:  z.string().min(10),
  source:   z.string().max(200).optional(),
});

export const RetrieveChunksSchema = z.object({
  category: z.enum(['therapy_protocol', 'diet_guideline', 'assessment_rubric', 'behavior_strategy', 'home_activity', 'general']).optional(),
  limit:    z.number().int().min(1).max(20).default(5),
});

export type AddDocumentInput = z.infer<typeof AddDocumentSchema>;
export type RetrieveChunksInput = z.infer<typeof RetrieveChunksSchema>;
