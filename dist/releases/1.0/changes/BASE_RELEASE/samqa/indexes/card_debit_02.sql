-- liquibase formatted sql
-- changeset SAMQA:1754373929967 stripComments:false logicalFilePath:BASE_RELEASE\samqa\indexes\card_debit_02.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/indexes/card_debit_02.sql:null:03a9885c213d1dfc604f82dd0550e2c110cf28de:create

create index samqa.card_debit_02 on
    samqa.card_debit (
        emitent
    );

