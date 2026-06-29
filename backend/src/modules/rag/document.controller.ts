import { Request, Response } from 'express';
import mongoose from 'mongoose';

import documentService from './document.service';
import { DocumentModel } from '../../models/document';

import {DeleteDocumentRequest,UploadDocumentRequest,FetchDocumentRequest} from '../../models/document.request.types';





export const uploadDocument = async (
    req: UploadDocumentRequest,
    res: Response,
): Promise<Response | void> => {
    try {
        const  centerId  = req.params.centerId;

        const file = req.file;

        const metadata = req.body.metadata
            ? JSON.parse(req.body.metadata)
            : {};

        const document =
            await documentService.processDocument(
                centerId,
                file!,
                metadata,
            );


     res.status(200).json({
         message: 'Document uploaded successfully.',
         body: {
             id: document.id,
             filename: document.filename,
             status: document.status
         }
     })

    } catch (error) {
        console.error(
            'Error uploading document:',
            error,
        );
        // if (error?.message.toString().includes('Empty')) {
        //     return errorResponse(
        //         res,
        //         400,
        //         "The document is empty",
        //         error,
        //     )
        // }

        res.status(500).json({
            message: 'Error uploading document:',
        })
    }
};

export const fetchDocuments = async (
    req: FetchDocumentRequest,
    res: Response,
): Promise<Response | void> => {
    try {
        const centerId  = req.params.centerId!;

        const page =
            parseInt(req.query.page as string) || 1;

        const limit =
            parseInt(req.query.limit as string) || 10;

        const result =
            await documentService.getDocuments(
                centerId,
                page,
                limit,
            );

        res.status(200).json({
            message: 'Documents found successfully.',
            body: result,
        })
    } catch (error) {
        console.error(
            'Error fetching documents:',
            error,
        );

       res.status(500).json({
           message: 'Error fetching documents:',
       })
    }
};


export const deleteDocument = async (
    req: DeleteDocumentRequest,
    res: Response,
): Promise<Response | void> => {
    try {
        const { centerId, documentId } = req.params;

        const document = await DocumentModel.findOne({
            _id: documentId,
            center_id: centerId,
        });

        if (!document) {
            return res.status(404).json({
                message: 'Document not found.',
            });
        }

        await documentService.deleteDocument(
            centerId,
            documentId,
        );

        return res.status(200).json({
            message: 'Document deleted successfully.',
        });
    } catch (error) {
        console.error('Error deleting document:', error);

        return res.status(500).json({
            message: 'Error deleting document.',
        });
    }
};