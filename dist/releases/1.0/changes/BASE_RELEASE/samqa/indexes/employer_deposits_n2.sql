-- liquibase formatted sql
-- changeset SAMQA:1754373930916 stripComments:false logicalFilePath:BASE_RELEASE\samqa\indexes\employer_deposits_n2.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/indexes/employer_deposits_n2.sql:null:522398a7a2f97b4b300bebf0debb806da64368e2:create

create index samqa.employer_deposits_n2 on
    samqa.employer_deposits (
        reason_code
    );

