-- liquibase formatted sql
-- changeset SAMQA:1754373936317 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.package_spec.pc_notification2.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.package_spec.pc_notification2.sql:null:25a81e68313b11fa818ae81cd69fc3a360c8441f:create

grant execute on samqa.pc_notification2 to rl_sam_rw;

grant execute on samqa.pc_notification2 to rl_sam1_ro;

grant execute on samqa.pc_notification2 to rl_sam_ro;

grant debug on samqa.pc_notification2 to rl_sam_rw;

grant debug on samqa.pc_notification2 to rl_sam1_ro;

grant debug on samqa.pc_notification2 to rl_sam_ro;

