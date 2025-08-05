-- liquibase formatted sql
-- changeset SAMQA:1754373931128 stripComments:false logicalFilePath:BASE_RELEASE\samqa\indexes\employer_payments_n1.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/indexes/employer_payments_n1.sql:null:a18c8a0855bffd9871071c87db229f000ae971d9:create

create index samqa.employer_payments_n1 on
    samqa.employer_payments (
        entrp_id
    );

