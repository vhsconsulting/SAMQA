-- liquibase formatted sql
-- changeset SAMQA:1754373935658 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.package_spec.aop_modal_api_pkg.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.package_spec.aop_modal_api_pkg.sql:null:f3e096b417964ca736bec825391987b69678cb30:create

grant execute on samqa.aop_modal_api_pkg to rl_sam1_ro;

grant execute on samqa.aop_modal_api_pkg to rl_sam_rw;

grant execute on samqa.aop_modal_api_pkg to rl_sam_ro;

grant debug on samqa.aop_modal_api_pkg to rl_sam_ro;

grant debug on samqa.aop_modal_api_pkg to rl_sam1_ro;

grant debug on samqa.aop_modal_api_pkg to rl_sam_rw;

