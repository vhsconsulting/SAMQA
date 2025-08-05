-- liquibase formatted sql
-- changeset SAMQA:1754373943604 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.view.emp_contrib_detail_v.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.view.emp_contrib_detail_v.sql:null:c451fd3bfc89cc9a479250514c938af04895b860:create

grant select on samqa.emp_contrib_detail_v to rl_sam1_ro;

grant select on samqa.emp_contrib_detail_v to rl_sam_rw;

grant select on samqa.emp_contrib_detail_v to rl_sam_ro;

grant select on samqa.emp_contrib_detail_v to sgali;

