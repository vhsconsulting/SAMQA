-- liquibase formatted sql
-- changeset SAMQA:1754373939624 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.table.debit_card_adjust.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.table.debit_card_adjust.sql:null:dd5cc2ea10503994e3c75fef0dd842106bcfc20d:create

grant delete on samqa.debit_card_adjust to rl_sam_rw;

grant insert on samqa.debit_card_adjust to rl_sam_rw;

grant select on samqa.debit_card_adjust to rl_sam1_ro;

grant select on samqa.debit_card_adjust to rl_sam_rw;

grant select on samqa.debit_card_adjust to rl_sam_ro;

grant update on samqa.debit_card_adjust to rl_sam_rw;

