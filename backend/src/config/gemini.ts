import { GoogleGenerativeAI } from '@google/generative-ai';

let _client: GoogleGenerativeAI | null = null;

export function getGeminiClient(): GoogleGenerativeAI {
  if (!process.env.GEMINI_API_KEY) {
    throw new Error('GEMINI_API_KEY environment variable is not set');
  }
  if (!_client) {
    _client = new GoogleGenerativeAI(process.env.GEMINI_API_KEY);
  }
  return _client;
}

export const GEMINI_MODEL = 'gemini-1.5-flash';

export async function generateText(prompt: string): Promise<{ text: string; inputTokens: number; outputTokens: number }> {
  const client = getGeminiClient();
  const model  = client.getGenerativeModel({
    model: GEMINI_MODEL,
    generationConfig: { maxOutputTokens: 2048 },
  });
  const start  = Date.now();
  const result = await model.generateContent(prompt);
  void start;
  const response   = result.response;
  const text       = response.text();
  const usage      = response.usageMetadata;
  return {
    text,
    inputTokens:  usage?.promptTokenCount     ?? 0,
    outputTokens: usage?.candidatesTokenCount ?? 0,
  };
}
