-- liquibase formatted sql
-- changeset SAMQA:1754373930935 stripComments:false logicalFilePath:BASE_RELEASE\samqa\indexes\employer_deposits_n6.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/indexes/employer_deposits_n6.sql:null:8e2bede5629be8c9537be6a88a5b2b87626a330b:create

create index samqa.employer_deposits_n6 on
    samqa.employer_deposits (
        entrp_id,
    trunc(check_date) );

