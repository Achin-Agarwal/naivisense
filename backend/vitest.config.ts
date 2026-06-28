import { defineConfig } from 'vitest/config';

export default defineConfig({
  test: {
    fileParallelism: false,
    env: {
      NODE_ENV:              'test',
      PORT:                  '8000',
      MONGO_URL:             'mongodb://localhost:27017/test',
      REDIS_URL:             'redis://localhost:6379',
      JWT_ACCESS_SECRET:     'test-access-secret-key-minimum-32-chars-abc!!',
      JWT_REFRESH_SECRET:    'test-refresh-secret-key-minimum-32-chars-xyz!',
      ACCESS_TOKEN_EXPIRES:  '15m',
      REFRESH_TOKEN_EXPIRES: '7d',
      S3_BUCKET:             'test-bucket',
      S3_REGION:             'ap-south-1',
      AWS_ACCESS_KEY_ID:     'test-aws-key-id',
      AWS_SECRET_ACCESS_KEY: 'test-aws-secret-key',
      AI_SERVICE_URL:        'http://localhost:8001',
      AI_SERVICE_TOKEN:      'test-service-token-32chars-abc!!',
      ALLOWED_ORIGIN:        '*',
    },
  },
});
