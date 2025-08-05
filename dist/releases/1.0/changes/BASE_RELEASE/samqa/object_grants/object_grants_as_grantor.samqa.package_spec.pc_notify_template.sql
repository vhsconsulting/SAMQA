-- liquibase formatted sql
-- changeset SAMQA:1754373936335 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.package_spec.pc_notify_template.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.package_spec.pc_notify_template.sql:null:91a6011e3358ae4ee930e71e3f2912d88e6d0ed0:create

grant execute on samqa.pc_notify_template to rl_sam_ro;

grant execute on samqa.pc_notify_template to rl_sam_rw;

grant execute on samqa.pc_notify_template to rl_sam1_ro;

grant debug on samqa.pc_notify_template to rl_sam_ro;

grant debug on samqa.pc_notify_template to sgali;

grant debug on samqa.pc_notify_template to rl_sam_rw;

grant debug on samqa.pc_notify_template to rl_sam1_ro;

