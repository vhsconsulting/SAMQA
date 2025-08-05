-- liquibase formatted sql
-- changeset SAMQA:1754373937115 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.procedure.reprocess_crmc_error_claims.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.procedure.reprocess_crmc_error_claims.sql:null:fe937bb7fa2b6165ff38008c5ea1f11c0a8ec51d:create

grant execute on samqa.reprocess_crmc_error_claims to rl_sam_ro;

grant execute on samqa.reprocess_crmc_error_claims to rl_sam_rw;

grant execute on samqa.reprocess_crmc_error_claims to rl_sam1_ro;

grant debug on samqa.reprocess_crmc_error_claims to sgali;

grant debug on samqa.reprocess_crmc_error_claims to rl_sam_rw;

grant debug on samqa.reprocess_crmc_error_claims to rl_sam1_ro;

