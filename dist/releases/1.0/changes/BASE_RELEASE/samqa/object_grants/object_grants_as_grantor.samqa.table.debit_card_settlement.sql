-- liquibase formatted sql
-- changeset SAMQA:1754373939647 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.table.debit_card_settlement.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.table.debit_card_settlement.sql:null:412bb693d1ff4ac7f7f2b8646722a2dcc8463d57:create

grant delete on samqa.debit_card_settlement to rl_sam_rw;

grant insert on samqa.debit_card_settlement to rl_sam_rw;

grant select on samqa.debit_card_settlement to rl_sam1_ro;

grant select on samqa.debit_card_settlement to rl_sam_rw;

grant select on samqa.debit_card_settlement to rl_sam_ro;

grant update on samqa.debit_card_settlement to rl_sam_rw;

