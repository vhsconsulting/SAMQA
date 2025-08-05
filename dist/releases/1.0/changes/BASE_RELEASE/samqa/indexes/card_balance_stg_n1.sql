-- liquibase formatted sql
-- changeset SAMQA:1754373929944 stripComments:false logicalFilePath:BASE_RELEASE\samqa\indexes\card_balance_stg_n1.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/indexes/card_balance_stg_n1.sql:null:1af4a0f745d291146a71fdbc1b00e2790d44f9ab:create

create index samqa.card_balance_stg_n1 on
    samqa.card_balance_stg (
        employee_id
    );

