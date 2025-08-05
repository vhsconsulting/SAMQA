-- liquibase formatted sql
-- changeset SAMQA:1754373931154 stripComments:false logicalFilePath:BASE_RELEASE\samqa\indexes\employer_payments_n3.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/indexes/employer_payments_n3.sql:null:b704b599aa43660f7b90407393e0e69ed8070542:create

create index samqa.employer_payments_n3 on
    samqa.employer_payments ( trunc(check_date) );

