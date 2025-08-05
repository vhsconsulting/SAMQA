-- liquibase formatted sql
-- changeset SAMQA:1754373943085 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.view.broker_emp_v.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.view.broker_emp_v.sql:null:a1cec09d5de7510202478c36dee09660468bd4c8:create

grant select on samqa.broker_emp_v to rl_sam1_ro;

grant select on samqa.broker_emp_v to rl_sam_rw;

grant select on samqa.broker_emp_v to rl_sam_ro;

grant select on samqa.broker_emp_v to sgali;

