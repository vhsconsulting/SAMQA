-- liquibase formatted sql
-- changeset SAMQA:1754373943675 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.view.employee_npm_qb_v.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.view.employee_npm_qb_v.sql:null:75ff4521adc5159b4665988a69600bfe6d4b1518:create

grant select on samqa.employee_npm_qb_v to rl_sam1_ro;

grant select on samqa.employee_npm_qb_v to public;

grant select on samqa.employee_npm_qb_v to rl_sam_ro;

grant select on samqa.employee_npm_qb_v to rl_sam_rw;

