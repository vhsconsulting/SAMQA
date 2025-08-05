-- liquibase formatted sql
-- changeset SAMQA:1754373941134 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.table.metavante_card_balances.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.table.metavante_card_balances.sql:null:6102ff3c443126d9488bb086e4c7b7fb34549da2:create

grant delete on samqa.metavante_card_balances to rl_sam_rw;

grant insert on samqa.metavante_card_balances to rl_sam_rw;

grant select on samqa.metavante_card_balances to rl_sam1_ro;

grant select on samqa.metavante_card_balances to rl_sam_rw;

grant select on samqa.metavante_card_balances to rl_sam_ro;

grant update on samqa.metavante_card_balances to rl_sam_rw;

