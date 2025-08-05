-- liquibase formatted sql
-- changeset SAMQA:1754373936369 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.package_spec.pc_opportunity_pkg.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.package_spec.pc_opportunity_pkg.sql:null:ec04f22db4f424b662cf6589b42a43648de48847:create

grant execute on samqa.pc_opportunity_pkg to rl_sam_ro;

grant debug on samqa.pc_opportunity_pkg to rl_sam_ro;

