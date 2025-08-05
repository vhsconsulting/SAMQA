-- liquibase formatted sql
-- changeset SAMQA:1754373943597 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.view.emp_broker_assign_v.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.view.emp_broker_assign_v.sql:null:2e6b5a580bce8c700b26f6468b1fbdfc13dbbed4:create

grant select on samqa.emp_broker_assign_v to rl_sam1_ro;

grant select on samqa.emp_broker_assign_v to rl_sam_rw;

grant select on samqa.emp_broker_assign_v to rl_sam_ro;

grant select on samqa.emp_broker_assign_v to sgali;

