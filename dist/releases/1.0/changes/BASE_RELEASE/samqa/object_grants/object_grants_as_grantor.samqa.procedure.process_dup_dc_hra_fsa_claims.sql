-- liquibase formatted sql
-- changeset SAMQA:1754373937013 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.procedure.process_dup_dc_hra_fsa_claims.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.procedure.process_dup_dc_hra_fsa_claims.sql:null:3b9e2541dbfab86a500007456b7cac6e1f73c34a:create

grant execute on samqa.process_dup_dc_hra_fsa_claims to rl_sam_ro;

grant execute on samqa.process_dup_dc_hra_fsa_claims to rl_sam_rw;

grant execute on samqa.process_dup_dc_hra_fsa_claims to rl_sam1_ro;

grant debug on samqa.process_dup_dc_hra_fsa_claims to sgali;

grant debug on samqa.process_dup_dc_hra_fsa_claims to rl_sam_rw;

grant debug on samqa.process_dup_dc_hra_fsa_claims to rl_sam1_ro;

