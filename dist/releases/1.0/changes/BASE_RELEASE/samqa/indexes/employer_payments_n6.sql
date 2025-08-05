-- liquibase formatted sql
-- changeset SAMQA:1754373931191 stripComments:false logicalFilePath:BASE_RELEASE\samqa\indexes\employer_payments_n6.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/indexes/employer_payments_n6.sql:null:92d56f3bc34c281e40df314b5c1a8ac24cde497b:create

create index samqa.employer_payments_n6 on
    samqa.employer_payments (
        payment_register_id
    );

