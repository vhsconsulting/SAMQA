-- liquibase formatted sql
-- changeset SAMQA:1754373931218 stripComments:false logicalFilePath:BASE_RELEASE\samqa\indexes\employer_payments_n9.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/indexes/employer_payments_n9.sql:null:ac364806009f83ad7723d97fae717b346ed29e20:create

create index samqa.employer_payments_n9 on
    samqa.employer_payments (
        transaction_source
    );

