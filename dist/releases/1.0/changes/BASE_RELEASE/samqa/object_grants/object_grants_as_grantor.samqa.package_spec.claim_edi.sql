-- liquibase formatted sql
-- changeset SAMQA:1754373935716 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.package_spec.claim_edi.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.package_spec.claim_edi.sql:null:850c40b8dc7286409828b35ddfc0f711fb0fdea1:create

grant execute on samqa.claim_edi to rl_sam_ro;

grant execute on samqa.claim_edi to rl_sam_rw;

grant execute on samqa.claim_edi to rl_sam1_ro;

grant debug on samqa.claim_edi to rl_sam_ro;

grant debug on samqa.claim_edi to sgali;

grant debug on samqa.claim_edi to rl_sam_rw;

grant debug on samqa.claim_edi to rl_sam1_ro;

