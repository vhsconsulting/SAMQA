-- liquibase formatted sql
-- changeset SAMQA:1754373937476 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.sequence.claim_edi_service_det_seq.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.sequence.claim_edi_service_det_seq.sql:null:9292de001f0606851b89aee4a652bd23c5dffcd6:create

grant select on samqa.claim_edi_service_det_seq to rl_sam_rw;

