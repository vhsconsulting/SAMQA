-- liquibase formatted sql
-- changeset SAMQA:1754373930700 stripComments:false logicalFilePath:BASE_RELEASE\samqa\indexes\debit_card_request_n1.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/indexes/debit_card_request_n1.sql:null:55c5e4b7bf52290292135d02b3535b552084d63c:create

create index samqa.debit_card_request_n1 on
    samqa.debit_card_request (
        card_id
    );

