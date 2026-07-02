import { Router }      from 'express';
import { requireAuth } from '../../middleware/auth';
import { upload }      from '../../middleware/upload';
import { uploadRateLimit } from '../../middleware/rate-limit';
import * as UsersCtrl  from './users.controller';

const router = Router();
router.post('/center-heads',                      UsersCtrl.enrollCenterHead);
router.use(requireAuth);

router.get('/therapists-overview',                UsersCtrl.getTherapistsOverview);             // center_head only
router.post('/therapists',                        UsersCtrl.enrollTherapist);                    // center_head only
router.post('/parents',                           UsersCtrl.enrollParent);                       // center_head only
router.post('/staff',                             UsersCtrl.enrollStaff);                        // center_head only — lead_therapist|dietician|clinical_psychologist
router.post('/therapists/:id/:docType',           uploadRateLimit, upload.single('file'), UsersCtrl.uploadTherapistDocument); // center_head only
router.get('/staff',                              UsersCtrl.listStaff);                          // ?role=<any role>
router.get('/',                                   UsersCtrl.getMe);
router.get('/me',                                 UsersCtrl.getMe);
router.patch('/me',                               UsersCtrl.updateMe);
router.post('/me/photo',                          uploadRateLimit, upload.single('photo'), UsersCtrl.uploadPhoto);
router.get('/:id',                                UsersCtrl.getUser);                // must be last

export default router;
