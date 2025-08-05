-- liquibase formatted sql
-- changeset SAMQA:1754373936178 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.package_spec.pc_file_upload.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.package_spec.pc_file_upload.sql:null:44783bd4cf695b5a01d02fe5dd7aa327ae6353f4:create

grant execute on samqa.pc_file_upload to rl_sam_ro;

grant execute on samqa.pc_file_upload to rl_sam_rw;

grant execute on samqa.pc_file_upload to rl_sam1_ro;

grant debug on samqa.pc_file_upload to sgali;

grant debug on samqa.pc_file_upload to rl_sam_rw;

grant debug on samqa.pc_file_upload to rl_sam1_ro;

grant debug on samqa.pc_file_upload to rl_sam_ro;

