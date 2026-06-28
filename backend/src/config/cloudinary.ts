import { v2 as cloudinary } from 'cloudinary';
import { env } from './env';

cloudinary.config({
  cloud_name: env.CLOUDINARY_CLOUD_NAME,
  api_key:    env.CLOUDINARY_API_KEY,
  api_secret: env.CLOUDINARY_API_SECRET,
  secure:     true,
});

function assertCloudinaryConfigured() {
  if (!env.CLOUDINARY_CLOUD_NAME || !env.CLOUDINARY_API_KEY || !env.CLOUDINARY_API_SECRET) {
    throw new Error('Cloudinary credentials are not configured');
  }
}

export async function uploadToCloudinary(
  buffer: Buffer,
  folder: string,
  publicId: string,
  mimetype: string,
): Promise<string> {
  const { url } = await uploadToCloudinaryFull(buffer, folder, publicId, mimetype);
  return url;
}

export async function uploadToCloudinaryFull(
  buffer: Buffer,
  folder: string,
  publicId: string,
  mimetype: string,
): Promise<{ url: string; public_id: string }> {
  assertCloudinaryConfigured();
  const resourceType = mimetype.startsWith('image/')
    ? 'image'
    : mimetype.startsWith('video/')
    ? 'video'
    : 'raw';
  return new Promise((resolve, reject) => {
    cloudinary.uploader.upload_stream(
      { folder, public_id: publicId, resource_type: resourceType, overwrite: true },
      (error, result) => {
        if (error || !result) return reject(error ?? new Error('Upload failed'));
        resolve({ url: result.secure_url, public_id: result.public_id });
      },
    ).end(buffer);
  });
}
