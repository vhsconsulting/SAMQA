-- liquibase formatted sql
-- changeset SAMQA:1754373929928 stripComments:false logicalFilePath:BASE_RELEASE\samqa\indexes\card_balance_external_n1.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/indexes/card_balance_external_n1.sql:null:8cee21bc9da7483702fc14d61bbe3e6e65f63fb4:create

create index samqa.card_balance_external_n1 on
    samqa.card_balance_gt (
        employee_id
    );

