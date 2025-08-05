-- liquibase formatted sql
-- changeset SAMQA:1754373931199 stripComments:false logicalFilePath:BASE_RELEASE\samqa\indexes\employer_payments_n7.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/indexes/employer_payments_n7.sql:null:624db3df609cc19940a22acd88f6e5795d82975b:create

create index samqa.employer_payments_n7 on
    samqa.employer_payments (
        check_date
    );

