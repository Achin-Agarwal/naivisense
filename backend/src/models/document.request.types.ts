import  {Request} from  'express'


interface DeleteDocumentParams {
    centerId: string;
    documentId: string;
}

interface UploadDocumentBody {
    metadata?: string;
}

interface UploadDocumentParams {
    centerId: string;
}

interface FetchDocumentsQuery {
    page?: string;
    limit?: string;
}

export interface UploadDocumentRequest
    extends Request<
        UploadDocumentParams,
        any,
        UploadDocumentBody
    > {
    file?: Express.Multer.File;
}

interface  centerParams {
    centerId: string;
}

export interface FetchDocumentRequest extends  Request<centerParams,FetchDocumentsQuery,any>{}


export interface DeleteDocumentRequest extends Request<DeleteDocumentParams,any,any> {}