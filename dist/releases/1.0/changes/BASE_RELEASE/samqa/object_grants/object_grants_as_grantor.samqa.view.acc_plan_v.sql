-- liquibase formatted sql
-- changeset SAMQA:1754373942696 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.view.acc_plan_v.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.view.acc_plan_v.sql:null:f7ee710ae6912a982d8aceb318c89dac13203a5c:create

grant select on samqa.acc_plan_v to sgali;

grant select on samqa.acc_plan_v to rl_sam1_ro;

grant select on samqa.acc_plan_v to rl_sam_rw;

grant select on samqa.acc_plan_v to rl_sam_ro;

