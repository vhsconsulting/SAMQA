-- liquibase formatted sql
-- changeset SAMQA:1754373939156 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.table.card_balance_gt.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.table.card_balance_gt.sql:null:4e967efea1896dd3195304ca166a95ba67e542b1:create

grant delete on samqa.card_balance_gt to rl_sam_rw;

grant insert on samqa.card_balance_gt to rl_sam_rw;

grant select on samqa.card_balance_gt to rl_sam1_ro;

grant select on samqa.card_balance_gt to rl_sam_rw;

grant select on samqa.card_balance_gt to rl_sam_ro;

grant update on samqa.card_balance_gt to rl_sam_rw;

