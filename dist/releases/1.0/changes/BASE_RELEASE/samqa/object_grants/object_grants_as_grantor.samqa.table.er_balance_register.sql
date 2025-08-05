-- liquibase formatted sql
-- changeset SAMQA:1754373940313 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.table.er_balance_register.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.table.er_balance_register.sql:null:6b51c0e1fa005fd8957a1fee16671d736abaedbc:create

grant delete on samqa.er_balance_register to rl_sam_rw;

grant insert on samqa.er_balance_register to rl_sam_rw;

grant select on samqa.er_balance_register to rl_sam1_ro;

grant select on samqa.er_balance_register to rl_sam_rw;

grant select on samqa.er_balance_register to rl_sam_ro;

grant update on samqa.er_balance_register to rl_sam_rw;

