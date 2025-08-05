-- liquibase formatted sql
-- changeset SAMQA:1754373932042 stripComments:false logicalFilePath:BASE_RELEASE\samqa\indexes\metavante_card_balances_n1.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/indexes/metavante_card_balances_n1.sql:null:6f03b7a61fe6ee080f0d2c41046e2822067db198:create

create index samqa.metavante_card_balances_n1 on
    samqa.metavante_card_balances (
        card_number
    );

