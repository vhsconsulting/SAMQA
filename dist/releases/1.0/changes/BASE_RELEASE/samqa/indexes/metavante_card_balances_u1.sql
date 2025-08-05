-- liquibase formatted sql
-- changeset SAMQA:1754373932065 stripComments:false logicalFilePath:BASE_RELEASE\samqa\indexes\metavante_card_balances_u1.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/indexes/metavante_card_balances_u1.sql:null:6bbf9b2c21b5d4814d2e0c7243d51200ff191350:create

create index samqa.metavante_card_balances_u1 on
    samqa.metavante_card_balances (
        acc_num
    );

