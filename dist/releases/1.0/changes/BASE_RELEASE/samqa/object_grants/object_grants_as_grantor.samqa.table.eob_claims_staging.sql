-- liquibase formatted sql
-- changeset SAMQA:1754373940222 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.table.eob_claims_staging.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.table.eob_claims_staging.sql:null:76bba961e76047cb72966740745d0d5f54b5466c:create

grant delete on samqa.eob_claims_staging to rl_sam_rw;

grant insert on samqa.eob_claims_staging to rl_sam_rw;

grant select on samqa.eob_claims_staging to rl_sam1_ro;

grant select on samqa.eob_claims_staging to rl_sam_rw;

grant select on samqa.eob_claims_staging to rl_sam_ro;

grant update on samqa.eob_claims_staging to rl_sam_rw;

