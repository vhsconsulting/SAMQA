-- liquibase formatted sql
-- changeset SAMQA:1754373935874 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.package_spec.pc_auto_process.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.package_spec.pc_auto_process.sql:null:6cd087cb703b6277b78f2f4d6928192ca77bbee8:create

grant execute on samqa.pc_auto_process to rl_sam_ro;

grant execute on samqa.pc_auto_process to rl_sam_rw;

grant execute on samqa.pc_auto_process to rl_sam1_ro;

grant debug on samqa.pc_auto_process to rl_sam_ro;

grant debug on samqa.pc_auto_process to sgali;

grant debug on samqa.pc_auto_process to rl_sam_rw;

grant debug on samqa.pc_auto_process to rl_sam1_ro;

