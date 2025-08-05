-- liquibase formatted sql
-- changeset SAMQA:1754373939183 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.table.card_transfer.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.table.card_transfer.sql:null:23c90ffabc02c3a1e71e076a8f70d2c4ddd82498:create

grant delete on samqa.card_transfer to rl_sam_rw;

grant insert on samqa.card_transfer to rl_sam_rw;

grant select on samqa.card_transfer to rl_sam1_ro;

grant select on samqa.card_transfer to rl_sam_rw;

grant select on samqa.card_transfer to rl_sam_ro;

grant update on samqa.card_transfer to rl_sam_rw;

