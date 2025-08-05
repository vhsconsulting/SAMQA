-- liquibase formatted sql
-- changeset SAMQA:1754373937048 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.procedure.process_warning_claims.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.procedure.process_warning_claims.sql:null:11a383828b7f03e7a560b39263fea9cce8e1b32f:create

grant execute on samqa.process_warning_claims to rl_sam_ro;

grant execute on samqa.process_warning_claims to rl_sam_rw;

grant execute on samqa.process_warning_claims to rl_sam1_ro;

grant debug on samqa.process_warning_claims to sgali;

grant debug on samqa.process_warning_claims to rl_sam_rw;

grant debug on samqa.process_warning_claims to rl_sam1_ro;

