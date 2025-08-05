-- liquibase formatted sql
-- changeset SAMQA:1754373936141 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.package_spec.pc_eob_upload.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.package_spec.pc_eob_upload.sql:null:ae48ccdde2aa50436b70048aa16f22c87954d61a:create

grant execute on samqa.pc_eob_upload to rl_sam_ro;

grant execute on samqa.pc_eob_upload to rl_sam_rw;

grant execute on samqa.pc_eob_upload to rl_sam1_ro;

grant debug on samqa.pc_eob_upload to sgali;

grant debug on samqa.pc_eob_upload to rl_sam_rw;

grant debug on samqa.pc_eob_upload to rl_sam1_ro;

grant debug on samqa.pc_eob_upload to rl_sam_ro;

