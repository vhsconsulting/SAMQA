-- liquibase formatted sql
-- changeset SAMQA:1754373939318 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.table.claim_edi_service_detail.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.table.claim_edi_service_detail.sql:null:9c4353f51e8ace53dc990d1eb5b058224c080941:create

grant delete on samqa.claim_edi_service_detail to rl_sam_rw;

grant insert on samqa.claim_edi_service_detail to rl_sam_rw;

grant select on samqa.claim_edi_service_detail to rl_sam1_ro;

grant select on samqa.claim_edi_service_detail to rl_sam_rw;

grant select on samqa.claim_edi_service_detail to rl_sam_ro;

grant update on samqa.claim_edi_service_detail to rl_sam_rw;

