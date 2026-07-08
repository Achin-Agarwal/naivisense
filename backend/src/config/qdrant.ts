
import { QdrantClient } from '@qdrant/js-client-rest';

const qdrantClient = new QdrantClient({
    url: process.env.QDRANT_URL,
    apiKey: process.env.QDRANT_API_KEY,
    checkCompatibility: false
});

export const initializeQdrant = async () => {
    const collections = await qdrantClient.getCollections();
    const collectionExists = collections.collections.some(
        (c) => c.name === 'document_chunks'
    );

    if (!collectionExists) {
        await qdrantClient.createCollection('document_chunks', {
            vectors: {
                size: 1536, // OpenAI embedding dimension
                distance: 'Cosine',
            },
        });

        // Create payload index for tenant isolation
        await qdrantClient.createPayloadIndex('document_chunks', {
            field_name: 'user_id',
            field_schema: 'keyword',
        });
    }
};

export default qdrantClient;


