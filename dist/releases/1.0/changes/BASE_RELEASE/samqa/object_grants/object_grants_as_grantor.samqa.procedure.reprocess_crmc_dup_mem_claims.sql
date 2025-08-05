-- liquibase formatted sql
-- changeset SAMQA:1754373937106 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.procedure.reprocess_crmc_dup_mem_claims.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.procedure.reprocess_crmc_dup_mem_claims.sql:null:e0267dd94894ad8a07ddb897707db854967e3103:create

grant execute on samqa.reprocess_crmc_dup_mem_claims to rl_sam_ro;

grant execute on samqa.reprocess_crmc_dup_mem_claims to rl_sam_rw;

grant execute on samqa.reprocess_crmc_dup_mem_claims to rl_sam1_ro;

grant debug on samqa.reprocess_crmc_dup_mem_claims to sgali;

grant debug on samqa.reprocess_crmc_dup_mem_claims to rl_sam_rw;

grant debug on samqa.reprocess_crmc_dup_mem_claims to rl_sam1_ro;

