-- liquibase formatted sql
-- changeset SAMQA:1754373939655 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.table.debit_card_updates.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.table.debit_card_updates.sql:null:3b547f68302b47985d0ab0ed0304b8cd746c6ca5:create

grant delete on samqa.debit_card_updates to rl_sam_rw;

grant insert on samqa.debit_card_updates to rl_sam_rw;

grant select on samqa.debit_card_updates to rl_sam1_ro;

grant select on samqa.debit_card_updates to rl_sam_rw;

grant select on samqa.debit_card_updates to rl_sam_ro;

grant update on samqa.debit_card_updates to rl_sam_rw;

