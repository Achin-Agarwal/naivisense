import { GoogleGenAI } from "@google/genai";

class EmbeddingService {
    private ai: GoogleGenAI;

    constructor() {
        this.ai = new GoogleGenAI({
            apiKey: process.env.GEMINI_API_KEY!,
        });
    }

    async generateEmbedding(text: string): Promise<number[]> {
        const response = await this.ai.models.embedContent({
            model: process.env.EMBEDDING_MODEL!,
            contents: text,
            config: {
                outputDimensionality: 1536,
            },
        });

        return response.embeddings ? response.embeddings[0].values as number[]:[];
    }

    async generateBatchEmbeddings(texts: string[]): Promise<number[][]> {
        const embeddings: number[][] = [];

        for (const text of texts) {
            const response = await this.ai.models.embedContent({
                model:  process.env.EMBEDDING_MODEL!,
                contents: text,
                config: {
                    outputDimensionality: 1536,
                },
            });

            if (response.embeddings) {
                embeddings.push(response.embeddings[0].values as number[]);
            }else {

            }
        }

        return embeddings;
    }
}

export default new EmbeddingService();