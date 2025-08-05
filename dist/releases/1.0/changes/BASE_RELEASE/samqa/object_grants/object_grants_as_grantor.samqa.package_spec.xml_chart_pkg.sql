-- liquibase formatted sql
-- changeset SAMQA:1754373936653 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.package_spec.xml_chart_pkg.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.package_spec.xml_chart_pkg.sql:null:613902fddd148aeee3f75ce89ec1e73a37e90361:create

grant execute on samqa.xml_chart_pkg to rl_sam_ro;

grant execute on samqa.xml_chart_pkg to rl_sam_rw;

grant execute on samqa.xml_chart_pkg to public;

grant execute on samqa.xml_chart_pkg to rl_sam1_ro;

grant debug on samqa.xml_chart_pkg to sgali;

grant debug on samqa.xml_chart_pkg to rl_sam_rw;

grant debug on samqa.xml_chart_pkg to rl_sam_ro;

grant debug on samqa.xml_chart_pkg to rl_sam1_ro;

