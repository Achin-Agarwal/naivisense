import { v4 as uuidv4 } from 'uuid';
import pdfParse, { Result } from 'pdf-parse';

import qdrantClient from '../../config/qdrant';
import embeddingService from './embedding.service';

import { DocumentModel } from '../../models/document';
import { DocumentChunkModel } from '../../models/document.chunks';

class DocumentServiceRag {
    private chunkSize = 1000;
    private chunkOverlap = 200;

    async extractTextFromPDF(buffer: Buffer): Promise<string> {
        const data: Result = await pdfParse(buffer);
        return data.text;
    }

    async extractTextFromFile(buffer: Buffer, mimeType: string): Promise<string> {
        if (mimeType === 'application/pdf') {
            return this.extractTextFromPDF(buffer);
        }

        if (mimeType === 'text/plain') {
            return buffer.toString('utf8');
        }

        throw new Error(`Unsupported file type: ${mimeType}`);
    }

    chunkText(text: string): string[] {
        const chunks: string[] = [];
        const words = text.split(/\s+/);

        let currentChunk: string[] = [];
        let currentLength = 0;

        for (const word of words) {
            if (
                currentLength + word.length + 1 > this.chunkSize &&
                currentChunk.length > 0
            ) {
                chunks.push(currentChunk.join(' '));

                const overlapWords = currentChunk.slice(
                    -Math.floor(this.chunkOverlap / 10)
                );

                currentChunk = [...overlapWords];
                currentLength = currentChunk.join(' ').length;
            }

            currentChunk.push(word);
            currentLength += word.length + 1;
        }

        if (currentChunk.length) {
            chunks.push(currentChunk.join(' '));
        }

        return chunks;
    }

    async processDocument(
        centerId: string,
        file: Express.Multer.File,
        metadata?: Record<string, any>,
    ) {
        const document = await DocumentModel.create({
            center_id: centerId,
            filename: file.originalname,
            file_size: file.size,
            mime_type: file.mimetype,
            metadata: metadata || {},
            status: 'PROCESSING',
        });

        try {
            const text = await this.extractTextFromFile(
                file.buffer,
                file.mimetype,
            );

            const chunks = this.chunkText(text);

            const embeddings =
                await embeddingService.generateBatchEmbeddings(chunks);

            const chunkDocs = [];
            const points = [];

            for (let i = 0; i < chunks.length; i++) {
                const vectorId = uuidv4();

                chunkDocs.push({
                    document_id: document._id,
                    center_id: centerId,
                    content: chunks[i],
                    chunk_index: i,
                    vector_id: vectorId,
                    metadata: {
                        chunkIndex: i,
                        ...metadata,
                    },
                });

                points.push({
                    id: vectorId,
                    vector: embeddings[i],
                    payload: {
                        center_id: centerId,
                        document_id: document._id.toString(),
                        chunk_index: i,
                        filename: file.originalname,
                        content: chunks[i],
                        metadata: JSON.stringify(metadata || {}),
                    },
                });
            }

            await DocumentChunkModel.insertMany(chunkDocs);

            await qdrantClient.upsert('document_chunks', {
                points,
            });

            document.status = 'PROCESSED';
            document.chunk_count = chunks.length;
            document.processed_at = new Date();

            await document.save();

            return document;
        } catch (err) {
            console.error(err);

            document.status = 'FAILED';
            await document.save();

            throw err;
        }
    }

    async getDocuments(
        centerId: string,
        page = 1,
        limit = 10,
    ) {
        const skip = (page - 1) * limit;

        const [documents, total] = await Promise.all([
            DocumentModel.find({
                center_id: centerId,
            })
                .sort({ uploaded_at: -1 })
                .skip(skip)
                .limit(limit)
                .select(
                    'filename file_size mime_type status chunk_count uploaded_at processed_at',
                ),

            DocumentModel.countDocuments({
                center_id: centerId,
            }),
        ]);

        return {
            documents,
            total,
            page,
            limit,
        };
    }

    async deleteDocument(centerId: string, documentId: string) {
        try {
            const chunks = await DocumentChunkModel.find({
                center_id: centerId,
                document_id: documentId,
            });

            const vectorIds = chunks.map((c) => c.vector_id);

            if (vectorIds.length) {
                await qdrantClient.delete('document_chunks', {
                    points: vectorIds,
                });
            }

            await DocumentChunkModel.deleteMany({
                center_id: centerId,
                document_id: documentId,
            });

            await DocumentModel.findOneAndDelete({
                _id: documentId,
                center_id: centerId,
            });

            return {
                success: true,
            };
        } catch (err) {
            console.error(err);
            throw err;
        }
    }
}

export default new DocumentServiceRag();