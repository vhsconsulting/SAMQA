-- liquibase formatted sql
-- changeset SAMQA:1754373929978 stripComments:false logicalFilePath:BASE_RELEASE\samqa\indexes\card_debit_n1.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/indexes/card_debit_n1.sql:null:95d2ae49b792404e33008e66984d74f0b090d143:create

create index samqa.card_debit_n1 on
    samqa.card_debit (
        status
    );

