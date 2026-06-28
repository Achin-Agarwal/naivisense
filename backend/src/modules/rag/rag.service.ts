import { KnowledgeDocumentModel } from '../../models/knowledge-document.model';
import { KnowledgeChunkModel }    from '../../models/knowledge-chunk.model';
import { AppError }               from '../../middleware/error';
import type { AuthPayload }       from '../../middleware/auth';
import type { AddDocumentInput }  from './rag.schema';

const CHUNK_SIZE = 1000; // chars per chunk

function chunkText(text: string): string[] {
  const chunks: string[] = [];
  for (let i = 0; i < text.length; i += CHUNK_SIZE) {
    chunks.push(text.slice(i, i + CHUNK_SIZE));
  }
  return chunks;
}

export async function addDocument(input: AddDocumentInput, user: AuthPayload) {
  if (user.role !== 'center_head') {
    throw new AppError('FORBIDDEN', 'Only center head can add knowledge documents');
  }

  const doc = await KnowledgeDocumentModel.create({
    ...input,
    uploaded_by: user.sub,
  });

  const chunks = chunkText(input.content);
  await KnowledgeChunkModel.insertMany(
    chunks.map((text, i) => ({
      document_id: doc._id,
      category:    input.category,
      chunk_index: i,
      text,
      char_count:  text.length,
    })),
  );

  return { document: doc, chunk_count: chunks.length };
}

export async function retrieveChunks(
  category: string | undefined,
  limit: number,
): Promise<string[]> {
  const filter: Record<string, unknown> = {};
  if (category) filter.category = category;

  const chunks = await KnowledgeChunkModel.find(filter)
    .sort({ created_at: -1 })
    .limit(limit)
    .lean();

  return chunks.map((c) => c.text);
}

export async function listDocuments(user: AuthPayload) {
  if (!['center_head', 'therapist', 'lead_therapist'].includes(user.role)) {
    throw new AppError('FORBIDDEN', 'Access denied');
  }
  return KnowledgeDocumentModel.find({ is_active: true })
    .select('title category source created_at')
    .sort({ created_at: -1 })
    .lean();
}
