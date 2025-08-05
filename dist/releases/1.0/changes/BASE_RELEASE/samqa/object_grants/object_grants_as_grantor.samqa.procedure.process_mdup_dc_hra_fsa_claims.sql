-- liquibase formatted sql
-- changeset SAMQA:1754373937028 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.procedure.process_mdup_dc_hra_fsa_claims.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.procedure.process_mdup_dc_hra_fsa_claims.sql:null:f09b6b24cc8a5978a63e4f61874455310b9116e3:create

grant execute on samqa.process_mdup_dc_hra_fsa_claims to rl_sam_ro;

grant execute on samqa.process_mdup_dc_hra_fsa_claims to rl_sam_rw;

grant execute on samqa.process_mdup_dc_hra_fsa_claims to rl_sam1_ro;

grant debug on samqa.process_mdup_dc_hra_fsa_claims to sgali;

grant debug on samqa.process_mdup_dc_hra_fsa_claims to rl_sam_rw;

grant debug on samqa.process_mdup_dc_hra_fsa_claims to rl_sam1_ro;

