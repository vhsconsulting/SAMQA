-- liquibase formatted sql
-- changeset SAMQA:1754373939631 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.table.debit_card_external.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.table.debit_card_external.sql:null:9f448ce221236f4cecb5d62a3e2e26c68e2ad157:create

grant delete on samqa.debit_card_external to rl_sam_rw;

grant insert on samqa.debit_card_external to rl_sam_rw;

grant select on samqa.debit_card_external to rl_sam1_ro;

grant select on samqa.debit_card_external to rl_sam_rw;

grant select on samqa.debit_card_external to rl_sam_ro;

grant update on samqa.debit_card_external to rl_sam_rw;

