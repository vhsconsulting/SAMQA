-- liquibase formatted sql
-- changeset SAMQA:1754373939175 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.table.card_debit.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.table.card_debit.sql:null:5a5bc7e2f910bda6c7d4ab97ba1aa814899fc4d2:create

grant delete on samqa.card_debit to rl_sam_rw;

grant insert on samqa.card_debit to rl_sam_rw;

grant select on samqa.card_debit to rl_sam1_ro;

grant select on samqa.card_debit to rl_sam_rw;

grant select on samqa.card_debit to rl_sam_ro;

grant update on samqa.card_debit to rl_sam_rw;

