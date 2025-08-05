-- liquibase formatted sql
-- changeset SAMQA:1754373943612 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.view.emp_contributions_v.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.view.emp_contributions_v.sql:null:d70e4cbdf8e2890fb95108bf14b3fde75e18d42a:create

grant select on samqa.emp_contributions_v to rl_sam1_ro;

grant select on samqa.emp_contributions_v to rl_sam_rw;

grant select on samqa.emp_contributions_v to rl_sam_ro;

grant select on samqa.emp_contributions_v to sgali;

