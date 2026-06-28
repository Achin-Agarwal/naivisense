import { Worker }                  from 'bullmq';
import { redis }                   from '../config/redis';
import logger                      from '../utils/logger';
import { KnowledgeDocumentModel }  from '../models/knowledge-document.model';
import { KnowledgeChunkModel }     from '../models/knowledge-chunk.model';
import { SessionModel }            from '../models/session.model';
import { AssessmentModel }         from '../models/assessment.model';
import { ReviewModel }             from '../models/review.model';

const CHUNK_SIZE = 1000;

function splitIntoChunks(text: string): string[] {
  const chunks: string[] = [];
  for (let i = 0; i < text.length; i += CHUNK_SIZE) {
    chunks.push(text.slice(i, i + CHUNK_SIZE));
  }
  return chunks;
}

async function rechunkDocument(documentId: string): Promise<void> {
  const doc = await KnowledgeDocumentModel.findById(documentId).lean();
  if (!doc || !doc.is_active) return;

  await KnowledgeChunkModel.deleteMany({ document_id: documentId });

  const chunks = splitIntoChunks(doc.content);
  if (chunks.length === 0) return;

  await KnowledgeChunkModel.insertMany(
    chunks.map((text, i) => ({
      document_id: doc._id,
      category:    doc.category,
      chunk_index: i,
      text,
      char_count:  text.length,
    })),
  );
  logger.info({ documentId, chunks: chunks.length }, 'Document re-chunked');
}

async function chunkFromSessionNotes(childId: string): Promise<void> {
  const recentSessions = await SessionModel.find({
    child_id: childId,
    status:   'completed',
    'notes.observations': { $exists: true, $ne: null },
  }).sort({ scheduled_at: -1 }).limit(3).lean();

  for (const sess of recentSessions) {
    if (!sess.notes?.observations) continue;
    const text = `Session observation (${sess.scheduled_at.toLocaleDateString()}): ${sess.notes.observations}`;
    await KnowledgeChunkModel.updateOne(
      { document_id: sess._id, chunk_index: 0 },
      {
        $setOnInsert: {
          document_id: sess._id,
          category:    'therapy_protocol',
          chunk_index: 0,
          text,
          char_count:  text.length,
        },
      },
      { upsert: true },
    );
  }
}

async function chunkFromAssessment(childId: string): Promise<void> {
  const assessment = await AssessmentModel.findOne({
    child_id:    childId,
    is_complete: true,
  }).sort({ date: -1 }).lean();

  if (!assessment) return;

  const parts: string[] = [
    `Assessment (${assessment.type}, ${assessment.date.toLocaleDateString()}):`,
    `Overall: ${assessment.overall_score_pct?.toFixed(0) ?? 'N/A'}%, Risk: ${assessment.risk_level}`,
  ];
  if (assessment.domain_scores) {
    const d = assessment.domain_scores;
    parts.push(
      `Domains — Attention: ${d.attention}, Communication: ${d.social_communication}, ` +
      `Receptive: ${d.receptive_language}, Expressive: ${d.expressive_language}`,
    );
  }
  const text = parts.join('\n');

  await KnowledgeChunkModel.updateOne(
    { document_id: assessment._id, chunk_index: 0 },
    {
      $setOnInsert: {
        document_id: assessment._id,
        category:    'assessment_rubric',
        chunk_index: 0,
        text,
        char_count:  text.length,
      },
    },
    { upsert: true },
  );
}

async function chunkFromReview(childId: string): Promise<void> {
  const review = await ReviewModel.findOne({
    child_id: childId,
    status:   'published',
  }).sort({ created_at: -1 }).lean();

  if (!review) return;

  const text =
    `${review.review_type} review ` +
    `(${review.period_start.toLocaleDateString()} – ${review.period_end.toLocaleDateString()}): ` +
    review.text_observations;

  await KnowledgeChunkModel.updateOne(
    { document_id: review._id, chunk_index: 0 },
    {
      $setOnInsert: {
        document_id: review._id,
        category:    'therapy_protocol',
        chunk_index: 0,
        text,
        char_count:  text.length,
      },
    },
    { upsert: true },
  );
}

export const chunkWorker = new Worker(
  'chunk.from-event',
  async (job) => {
    const { event_type, child_id, document_id } =
      job.data as { event_type: string; child_id?: string; document_id?: string };

    logger.info({ event_type, child_id, document_id }, 'Chunk job started');

    switch (event_type) {
      case 'document.added':
      case 'document.updated':
        if (document_id) await rechunkDocument(document_id);
        break;
      case 'session.completed':
        if (child_id) await chunkFromSessionNotes(child_id);
        break;
      case 'assessment.completed':
        if (child_id) await chunkFromAssessment(child_id);
        break;
      case 'review.published':
        if (child_id) await chunkFromReview(child_id);
        break;
      default:
        logger.warn({ event_type }, 'Unknown chunk event type');
    }
  },
  { connection: redis, concurrency: 10 },
);

chunkWorker.on('failed', (job, err) => {
  logger.error({ jobId: job?.id, err }, 'Chunk job failed');
});
