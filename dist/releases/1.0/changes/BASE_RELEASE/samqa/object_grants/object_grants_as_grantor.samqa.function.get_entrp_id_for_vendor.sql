-- liquibase formatted sql
-- changeset SAMQA:1754373935279 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.function.get_entrp_id_for_vendor.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.function.get_entrp_id_for_vendor.sql:null:084458d8774577bc720265b32c86889a9176872d:create

grant execute on samqa.get_entrp_id_for_vendor to rl_sam_rw;

grant execute on samqa.get_entrp_id_for_vendor to rl_sam1_ro;

grant execute on samqa.get_entrp_id_for_vendor to rl_sam_ro;

grant debug on samqa.get_entrp_id_for_vendor to rl_sam_rw;

grant debug on samqa.get_entrp_id_for_vendor to rl_sam1_ro;

