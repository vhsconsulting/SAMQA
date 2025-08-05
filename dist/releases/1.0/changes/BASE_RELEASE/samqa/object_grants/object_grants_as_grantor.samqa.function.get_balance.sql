-- liquibase formatted sql
-- changeset SAMQA:1754373935241 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.function.get_balance.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.function.get_balance.sql:null:1e572f0043d6958145ae00389b82041c3ac79c80:create

grant execute on samqa.get_balance to rl_sam_ro;

grant execute on samqa.get_balance to rl_sam_rw;

grant execute on samqa.get_balance to rl_sam1_ro;

grant debug on samqa.get_balance to sgali;

grant debug on samqa.get_balance to rl_sam_rw;

grant debug on samqa.get_balance to rl_sam1_ro;

