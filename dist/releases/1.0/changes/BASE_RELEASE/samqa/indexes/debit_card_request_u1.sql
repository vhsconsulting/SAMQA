-- liquibase formatted sql
-- changeset SAMQA:1754373930709 stripComments:false logicalFilePath:BASE_RELEASE\samqa\indexes\debit_card_request_u1.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/indexes/debit_card_request_u1.sql:null:a703927fef7d22b9df4301e83d76feecf69712de:create

create unique index samqa.debit_card_request_u1 on
    samqa.debit_card_request (
        debit_card_request_id
    );

