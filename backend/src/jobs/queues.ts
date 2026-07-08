import { Queue }  from 'bullmq';
import { env } from '../config/env';

const opts = { 
  connection: { 
    url: env.REDIS_URL,
    maxRetriesPerRequest: null,
    enableOfflineQueue: false,
    lazyConnect: true,
  }
};

export const snapshotQueue = new Queue('snapshot.rebuild', opts);
export const chunkQueue    = new Queue('chunk.from-event', opts);
export const embedQueue    = new Queue('embed.refresh',    opts);
export const reportQueue   = new Queue('report.monthly',   opts);
