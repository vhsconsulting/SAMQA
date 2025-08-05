-- liquibase formatted sql
-- changeset SAMQA:1754373939639 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.table.debit_card_request.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.table.debit_card_request.sql:null:497dfc4edaa7a11400ad5028b1db6137f370def6:create

grant delete on samqa.debit_card_request to rl_sam_rw;

grant insert on samqa.debit_card_request to rl_sam_rw;

grant select on samqa.debit_card_request to rl_sam1_ro;

grant select on samqa.debit_card_request to rl_sam_rw;

grant select on samqa.debit_card_request to rl_sam_ro;

grant update on samqa.debit_card_request to rl_sam_rw;

