-- liquibase formatted sql
-- changeset SAMQA:1754373943618 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.view.emp_health_plans_v.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.view.emp_health_plans_v.sql:null:43c933167e30e641129ca08f0776bfacf3ddd2e8:create

grant select on samqa.emp_health_plans_v to rl_sam1_ro;

grant select on samqa.emp_health_plans_v to rl_sam_rw;

grant select on samqa.emp_health_plans_v to rl_sam_ro;

grant select on samqa.emp_health_plans_v to sgali;

