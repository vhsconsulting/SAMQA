-- liquibase formatted sql
-- changeset SAMQA:1754373936797 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.procedure.delete_dup_cov_tier.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.procedure.delete_dup_cov_tier.sql:null:3590792a0589809de3f138de14597420c7dca1cf:create

grant execute on samqa.delete_dup_cov_tier to rl_sam_ro;

grant execute on samqa.delete_dup_cov_tier to rl_sam_rw;

grant execute on samqa.delete_dup_cov_tier to rl_sam1_ro;

grant debug on samqa.delete_dup_cov_tier to sgali;

grant debug on samqa.delete_dup_cov_tier to rl_sam_rw;

grant debug on samqa.delete_dup_cov_tier to rl_sam1_ro;

