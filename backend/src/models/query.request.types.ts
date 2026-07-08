import {Request} from 'express';

export  interface QueryRequestBody {
    query: string;
    topK?: number;
    minConfidence?: number;
}

export interface SourceDocument {
    id: string;
    content: string;
    filename: string;
    score: number;
    metadata?: Record<string, any>;
}



export interface QueryResponse {
    answer: string;
    sources: SourceDocument[];
    confidence: number;
    guardrailTriggered: boolean;
}

export  interface QueryRequest extends Request<any,any,QueryRequestBody>{}
