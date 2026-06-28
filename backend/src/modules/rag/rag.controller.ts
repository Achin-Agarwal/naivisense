import * as RagService    from './rag.service';
import { AddDocumentSchema, RetrieveChunksSchema } from './rag.schema';
import { asyncHandler }  from '../../utils/http';

export const addDocument = asyncHandler(async (req, res) => {
  const input  = AddDocumentSchema.parse(req.body);
  const result = await RagService.addDocument(input, req.user!);
  res.status(201).json(result);
});

export const retrieve = asyncHandler(async (req, res) => {
  const { category, limit } = RetrieveChunksSchema.parse(req.query);
  const chunks = await RagService.retrieveChunks(category, limit);
  res.json({ chunks });
});

export const listDocuments = asyncHandler(async (req, res) => {
  const docs = await RagService.listDocuments(req.user!);
  res.json(docs);
});
