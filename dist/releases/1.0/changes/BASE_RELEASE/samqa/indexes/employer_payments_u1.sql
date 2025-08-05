-- liquibase formatted sql
-- changeset SAMQA:1754373931228 stripComments:false logicalFilePath:BASE_RELEASE\samqa\indexes\employer_payments_u1.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/indexes/employer_payments_u1.sql:null:170e9b365b04750d029655e8895f7d19d4a1b136:create

create unique index samqa.employer_payments_u1 on
    samqa.employer_payments (
        employer_payment_id
    );

