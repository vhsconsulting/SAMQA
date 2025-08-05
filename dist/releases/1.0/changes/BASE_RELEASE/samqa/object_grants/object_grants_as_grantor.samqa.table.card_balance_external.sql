-- liquibase formatted sql
-- changeset SAMQA:1754373939145 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.table.card_balance_external.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.table.card_balance_external.sql:null:332a0e5ba3588d37454afd192b18b91a22f5e3a4:create

grant select on samqa.card_balance_external to rl_sam1_ro;

grant select on samqa.card_balance_external to rl_sam_ro;

