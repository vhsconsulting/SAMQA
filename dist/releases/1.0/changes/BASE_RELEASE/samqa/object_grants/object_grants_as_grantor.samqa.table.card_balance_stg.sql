-- liquibase formatted sql
-- changeset SAMQA:1754373939166 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.table.card_balance_stg.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.table.card_balance_stg.sql:null:29adf4934640b46eedaaed0714fd63f717125acd:create

grant delete on samqa.card_balance_stg to rl_sam_rw;

grant insert on samqa.card_balance_stg to rl_sam_rw;

grant select on samqa.card_balance_stg to rl_sam1_ro;

grant select on samqa.card_balance_stg to rl_sam_rw;

grant select on samqa.card_balance_stg to rl_sam_ro;

grant update on samqa.card_balance_stg to rl_sam_rw;

