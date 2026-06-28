import multer from 'multer';
import path from 'path';
import { AppError } from './error';

const IMAGE_TYPES: Record<string, string[]> = {
  'image/jpeg': ['.jpg', '.jpeg'],
  'image/png':  ['.png'],
  'image/webp': ['.webp'],
};

const VIDEO_TYPES: Record<string, string[]> = {
  'video/mp4':       ['.mp4'],
  'video/quicktime': ['.mov', '.qt'],
  'video/webm':      ['.webm'],
  'video/x-msvideo': ['.avi'],
};

const IMAGE_MAX_MB = 5;
const VIDEO_MAX_MB = 200;

function isAllowed(file: Express.Multer.File, allowed: Record<string, string[]>): boolean {
  const ext = path.extname(file.originalname).toLowerCase();
  return Boolean(allowed[file.mimetype]?.includes(ext));
}

export const upload = multer({
  storage: multer.memoryStorage(),
  limits:  { fileSize: IMAGE_MAX_MB * 1024 * 1024 },
  fileFilter: (_req, file, cb) => {
    if (isAllowed(file, IMAGE_TYPES)) {
      cb(null, true);
    } else {
      cb(new AppError('INVALID_INPUT', 'Only JPEG, PNG and WebP images with valid extensions are allowed'));
    }
  },
});

export const uploadVideo = multer({
  storage: multer.memoryStorage(),
  limits:  { fileSize: VIDEO_MAX_MB * 1024 * 1024 },
  fileFilter: (_req, file, cb) => {
    if (isAllowed(file, VIDEO_TYPES)) {
      cb(null, true);
    } else {
      cb(new AppError('INVALID_INPUT', 'Only MP4, MOV, WebM and AVI videos with valid extensions are allowed'));
    }
  },
});
