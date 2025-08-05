-- liquibase formatted sql
-- changeset SAMQA:1754373930925 stripComments:false logicalFilePath:BASE_RELEASE\samqa\indexes\employer_deposits_n3.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/indexes/employer_deposits_n3.sql:null:7b08d7d5904d2e512136c34b93a14f157c705b4c:create

create index samqa.employer_deposits_n3 on
    samqa.employer_deposits ( trunc(check_date) );

