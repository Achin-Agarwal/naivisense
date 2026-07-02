import { Worker } from 'bullmq';
import { env }  from '../config/env';
import logger     from '../utils/logger';

export const snapshotWorker = new Worker(
  'snapshot.rebuild',
  async (job) => {
    const { childId } = job.data as { childId: string };
    logger.info({ childId }, 'Snapshot rebuild queued — AI service not yet connected (stub)');
    // Full: POST to AI service /snapshot/rebuild/:childId
  },
  { 
    connection: { 
      url: env.REDIS_URL,
      maxRetriesPerRequest: null,
      enableOfflineQueue: false,
      lazyConnect: true,
    }, 
    concurrency: 5 
  },
);

snapshotWorker.on('failed', (job, err) => {
  logger.error({ jobId: job?.id, err }, 'Snapshot job failed');
});
