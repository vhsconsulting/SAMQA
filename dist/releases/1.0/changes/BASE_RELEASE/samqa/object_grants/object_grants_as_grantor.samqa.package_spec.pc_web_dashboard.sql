-- liquibase formatted sql
-- changeset SAMQA:1754373936567 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.package_spec.pc_web_dashboard.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.package_spec.pc_web_dashboard.sql:null:080f4a9b4de1bb70d352ac6eedc476736feaf2e4:create

grant execute on samqa.pc_web_dashboard to rl_sam_ro;

grant execute on samqa.pc_web_dashboard to rl_sam_rw;

grant execute on samqa.pc_web_dashboard to rl_sam1_ro;

grant debug on samqa.pc_web_dashboard to sgali;

grant debug on samqa.pc_web_dashboard to rl_sam_rw;

grant debug on samqa.pc_web_dashboard to rl_sam1_ro;

grant debug on samqa.pc_web_dashboard to rl_sam_ro;

