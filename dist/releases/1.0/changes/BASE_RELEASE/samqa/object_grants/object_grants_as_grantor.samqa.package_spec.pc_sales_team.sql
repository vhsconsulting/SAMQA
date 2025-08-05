-- liquibase formatted sql
-- changeset SAMQA:1754373936447 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.package_spec.pc_sales_team.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.package_spec.pc_sales_team.sql:null:1f763f398e25db31989f646360218e3ff0e540f0:create

grant execute on samqa.pc_sales_team to rl_sam_ro;

grant execute on samqa.pc_sales_team to rl_sam_rw;

grant execute on samqa.pc_sales_team to rl_sam1_ro;

grant debug on samqa.pc_sales_team to rl_sam1_ro;

grant debug on samqa.pc_sales_team to rl_sam_ro;

grant debug on samqa.pc_sales_team to sgali;

grant debug on samqa.pc_sales_team to rl_sam_rw;

