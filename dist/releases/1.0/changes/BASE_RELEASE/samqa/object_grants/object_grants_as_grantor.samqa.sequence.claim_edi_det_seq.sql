-- liquibase formatted sql
-- changeset SAMQA:1754373937468 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.sequence.claim_edi_det_seq.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.sequence.claim_edi_det_seq.sql:null:0ddea4e5f7e8cf3ab1eb01ffecb471eee4e5ee89:create

grant select on samqa.claim_edi_det_seq to rl_sam_rw;

