-- liquibase formatted sql
-- changeset SAMQA:1754373937688 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.sequence.enrollment_edi_det_seq.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.sequence.enrollment_edi_det_seq.sql:null:fcb1700f890c31f22bbb4d29c0ca452ee9b414bb:create

grant select on samqa.enrollment_edi_det_seq to rl_sam_rw;

