-- liquibase formatted sql
-- changeset SAMQA:1754373936326 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.package_spec.pc_notifications.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.package_spec.pc_notifications.sql:null:22e8907d4e264497f12d5091b3313780541e4725:create

grant execute on samqa.pc_notifications to rl_sam_ro;

grant execute on samqa.pc_notifications to rl_sam_rw;

grant execute on samqa.pc_notifications to rl_sam1_ro;

grant debug on samqa.pc_notifications to rl_sam_ro;

grant debug on samqa.pc_notifications to sgali;

grant debug on samqa.pc_notifications to rl_sam_rw;

grant debug on samqa.pc_notifications to rl_sam1_ro;

