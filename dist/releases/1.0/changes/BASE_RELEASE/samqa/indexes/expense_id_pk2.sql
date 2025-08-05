-- liquibase formatted sql
-- changeset SAMQA:1754373931468 stripComments:false logicalFilePath:BASE_RELEASE\samqa\indexes\expense_id_pk2.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/indexes/expense_id_pk2.sql:null:d74a2512b358c6fd0a7541450293aae02d1c4d04:create

create unique index samqa.expense_id_pk2 on
    samqa.eligibile_expenses_staging (
        expense_id
    );

