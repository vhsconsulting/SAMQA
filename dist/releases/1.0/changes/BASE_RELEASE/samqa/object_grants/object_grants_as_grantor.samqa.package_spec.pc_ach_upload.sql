-- liquibase formatted sql
-- changeset SAMQA:1754373935848 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.package_spec.pc_ach_upload.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.package_spec.pc_ach_upload.sql:null:8049d052bd8f2b18b6868c2b3ce79398a6ff4d9b:create

grant execute on samqa.pc_ach_upload to rl_sam1_ro;

grant execute on samqa.pc_ach_upload to rl_sam_ro;

grant execute on samqa.pc_ach_upload to rl_sam_rw;

grant debug on samqa.pc_ach_upload to sgali;

grant debug on samqa.pc_ach_upload to rl_sam_rw;

grant debug on samqa.pc_ach_upload to rl_sam1_ro;

grant debug on samqa.pc_ach_upload to rl_sam_ro;

