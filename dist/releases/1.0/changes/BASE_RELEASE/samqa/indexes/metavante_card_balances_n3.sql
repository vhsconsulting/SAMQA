-- liquibase formatted sql
-- changeset SAMQA:1754373932057 stripComments:false logicalFilePath:BASE_RELEASE\samqa\indexes\metavante_card_balances_n3.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/indexes/metavante_card_balances_n3.sql:null:205dbeb92287fa3566216dda2b0d4109d9df3d5e:create

create index samqa.metavante_card_balances_n3 on
    samqa.metavante_card_balances (
        acc_id
    );

