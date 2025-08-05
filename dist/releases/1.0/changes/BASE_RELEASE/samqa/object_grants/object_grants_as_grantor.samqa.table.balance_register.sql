-- liquibase formatted sql
-- changeset SAMQA:1754373938796 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.table.balance_register.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.table.balance_register.sql:null:02f713a0a2cea0ea0f92be008cbcff66d553accc:create

grant delete on samqa.balance_register to rl_sam_rw;

grant insert on samqa.balance_register to rl_sam_rw;

grant select on samqa.balance_register to rl_sam1_ro;

grant select on samqa.balance_register to rl_sam_rw;

grant select on samqa.balance_register to rl_sam_ro;

grant update on samqa.balance_register to rl_sam_rw;

