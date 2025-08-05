-- liquibase formatted sql
-- changeset SAMQA:1754373936910 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.procedure.insert_rate_plan.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.procedure.insert_rate_plan.sql:null:2c343e502693dad3cf943f15b8b736d2c6afae3a:create

grant execute on samqa.insert_rate_plan to rl_sam_ro;

grant execute on samqa.insert_rate_plan to rl_sam_rw;

grant execute on samqa.insert_rate_plan to rl_sam1_ro;

grant debug on samqa.insert_rate_plan to sgali;

grant debug on samqa.insert_rate_plan to rl_sam_rw;

grant debug on samqa.insert_rate_plan to rl_sam1_ro;

