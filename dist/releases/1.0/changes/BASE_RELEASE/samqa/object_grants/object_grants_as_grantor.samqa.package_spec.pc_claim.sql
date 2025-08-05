-- liquibase formatted sql
-- changeset SAMQA:1754373935933 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.package_spec.pc_claim.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.package_spec.pc_claim.sql:null:3537dc5384f3e831d97734ead8c63a10de723f97:create

grant execute on samqa.pc_claim to rl_sam_ro;

grant execute on samqa.pc_claim to rl_sam_rw;

grant execute on samqa.pc_claim to rl_sam1_ro;

grant debug on samqa.pc_claim to rl_sam_ro;

grant debug on samqa.pc_claim to sgali;

grant debug on samqa.pc_claim to rl_sam_rw;

grant debug on samqa.pc_claim to rl_sam1_ro;

