-- liquibase formatted sql
-- changeset SAMQA:1754373939303 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.table.claim_edi_external.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.table.claim_edi_external.sql:null:9f12b338c776db0ce428184afb0916d96db3280d:create

grant select on samqa.claim_edi_external to rl_sam1_ro;

grant select on samqa.claim_edi_external to rl_sam_ro;

