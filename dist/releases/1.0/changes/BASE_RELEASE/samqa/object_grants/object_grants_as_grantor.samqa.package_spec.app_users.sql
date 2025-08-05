-- liquibase formatted sql
-- changeset SAMQA:1754373935693 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.package_spec.app_users.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.package_spec.app_users.sql:null:0310185fb8f873603de95315ae46ce8fa3781af2:create

grant execute on samqa.app_users to rl_sam_ro;

grant execute on samqa.app_users to rl_sam_rw;

grant execute on samqa.app_users to rl_sam1_ro;

grant debug on samqa.app_users to rl_sam_ro;

grant debug on samqa.app_users to sgali;

grant debug on samqa.app_users to rl_sam_rw;

grant debug on samqa.app_users to rl_sam1_ro;

