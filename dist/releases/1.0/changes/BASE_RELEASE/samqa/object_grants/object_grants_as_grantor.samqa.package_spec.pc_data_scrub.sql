-- liquibase formatted sql
-- changeset SAMQA:1754373936034 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.package_spec.pc_data_scrub.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.package_spec.pc_data_scrub.sql:null:11a5f4808866fbe8e3cb41458a57b118ee7b8156:create

grant execute on samqa.pc_data_scrub to rl_sam_ro;

grant execute on samqa.pc_data_scrub to rl_sam_rw;

grant execute on samqa.pc_data_scrub to rl_sam1_ro;

grant debug on samqa.pc_data_scrub to sgali;

grant debug on samqa.pc_data_scrub to rl_sam_rw;

grant debug on samqa.pc_data_scrub to rl_sam1_ro;

grant debug on samqa.pc_data_scrub to rl_sam_ro;

