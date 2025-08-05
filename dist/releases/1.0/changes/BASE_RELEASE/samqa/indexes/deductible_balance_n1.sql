-- liquibase formatted sql
-- changeset SAMQA:1754373930717 stripComments:false logicalFilePath:BASE_RELEASE\samqa\indexes\deductible_balance_n1.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/indexes/deductible_balance_n1.sql:null:8c3dd54c0f95cf8027a26150be0ee0a815c6523d:create

create index samqa.deductible_balance_n1 on
    samqa.deductible_balance (
        acc_id
    );

