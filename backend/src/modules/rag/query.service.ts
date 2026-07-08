import mongoose from 'mongoose';

import qdrantClient from '../../config/qdrant';
import embeddingService from './embedding.service';
import llmService from './llm';

import { QueryLogModel } from '../../models/query.log';

import {
    QueryRequestBody,
    QueryResponse,
    SourceDocument,
} from '../../models/query.request.types';

class QueryService {
    private defaultTopK = 5;
    private minConfidence = 0.7;
    private cacheTTL = 3600;

    async query(
        centerId: string,
        request: QueryRequestBody
    ): Promise<QueryResponse> {
        const startTime = Date.now();
        let guardrailTriggered = false;

        const isInjection = await llmService.detectPromptInjection(
            request.query
        );

        if (isInjection) {
            const response: QueryResponse = {
                answer:
                    'I cannot process this request as it appears to contain instructions that could compromise system security.',
                sources: [],
                confidence: 0,
                guardrailTriggered: true,
            };

            await this.logQuery(
                centerId,
                request.query,
                response,
                startTime,
                true
            );

            return response;
        }

        const queryEmbedding =
            await embeddingService.generateEmbedding(request.query);

        const searchResult = await qdrantClient.search(
            'document_chunks',
            {
                vector: queryEmbedding,
                limit: request.topK || this.defaultTopK,

                filter: {
                    must: [
                        {
                            key: 'center_id',
                            match: {
                                value: centerId,
                            },
                        },
                    ],
                },

                score_threshold:
                    request.minConfidence ||
                    this.minConfidence,
            }
        );

        if (!searchResult || searchResult.length === 0) {
            const response: QueryResponse = {
                answer:
                    "I couldn't find relevant information in your knowledge base to answer this question. Please ensure your documents have been uploaded and processed.",
                sources: [],
                confidence: 0,
                guardrailTriggered: false,
            };

            await this.logQuery(
                centerId,
                request.query,
                response,
                startTime,
                false
            );

            return response;
        }

        const avgScore =
            searchResult.reduce(
                (sum, point) => sum + (point.score || 0),
                0
            ) / searchResult.length;

        const confidence = avgScore;

        if (
            confidence <
            (request.minConfidence ||
                this.minConfidence)
        ) {
            const response: QueryResponse = {
                answer:
                    'The system found some potentially relevant information, but confidence is too low to provide a reliable answer. Please try rephrasing your question or upload more relevant documents.',
                sources:
                    this.mapSearchResultsToSources(
                        searchResult
                    ),
                confidence,
                guardrailTriggered: false,
            };

            await this.logQuery(
                centerId,
                request.query,
                response,
                startTime,
                false
            );

            return response;
        }

        const context = searchResult
            .map((point) => point.payload?.content)
            .filter(Boolean)
            .join('\n\n');

        const answer =
            await llmService.generateResponse(
                context,
                request.query,
                centerId
            );

        const outOfScopeIndicators = [
            'cannot answer',
            'based on the available documents',
            'does not contain',
        ];

        const isOutOfScope =
            outOfScopeIndicators.some((indicator) =>
                answer
                    .toLowerCase()
                    .includes(indicator.toLowerCase())
            );

        const finalAnswer = isOutOfScope
            ? 'I cannot answer this question based on the documents in your knowledge base. Please ensure the information is available in uploaded documents or contact your administrator for assistance.'
            : answer;

        guardrailTriggered = isOutOfScope;

        const response: QueryResponse = {
            answer: finalAnswer,
            sources:
                this.mapSearchResultsToSources(
                    searchResult
                ),
            confidence,
            guardrailTriggered,
        };

        await this.logQuery(
            centerId,
            request.query,
            response,
            startTime,
            guardrailTriggered
        );

        return response;
    }

    private mapSearchResultsToSources(
        points: any[]
    ): SourceDocument[] {
        return points.map((point) => ({
            id: point.payload?.chunk_id,
            content: point.payload?.content,
            filename: point.payload?.filename,
            score: point.score || 0,

            metadata:
                typeof point.payload?.metadata ===
                'string'
                    ? JSON.parse(
                        point.payload.metadata
                    )
                    : point.payload?.metadata || {},
        }));
    }

    private async logQuery(
        centerId: string,
        query: string,
        response: QueryResponse,
        startTime: number,
        guardrailTriggered: boolean
    ): Promise<void> {
        try {
            const latency =
                Date.now() - startTime;

            await QueryLogModel.create({
                user_id:
                    new mongoose.Types.ObjectId(
                        centerId
                    ),

                query,
                response: response.answer,

                sources: response.sources,

                confidence:
                response.confidence,

                latency,

                guardrail_triggered:
                guardrailTriggered,
            });
        } catch (error) {
            console.error(
                'Failed to log query:',
                error
            );
        }
    }
}

export default new QueryService();