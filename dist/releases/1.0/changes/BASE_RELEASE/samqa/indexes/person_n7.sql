-- liquibase formatted sql
-- changeset SAMQA:1754373932919 stripComments:false logicalFilePath:BASE_RELEASE\samqa\indexes\person_n7.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/indexes/person_n7.sql:null:6498a97f23ea77b111e2f9b7345de4d0e5f5c325:create

create index samqa.person_n7 on
    samqa.person (
        ssn
    );

