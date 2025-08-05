-- liquibase formatted sql
-- changeset SAMQA:1754373931169 stripComments:false logicalFilePath:BASE_RELEASE\samqa\indexes\employer_payments_n4.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/indexes/employer_payments_n4.sql:null:49e9fd7b6b279b5550fc6202347cbf941cb0e1ac:create

create index samqa.employer_payments_n4 on
    samqa.employer_payments (
        list_bill
    );

