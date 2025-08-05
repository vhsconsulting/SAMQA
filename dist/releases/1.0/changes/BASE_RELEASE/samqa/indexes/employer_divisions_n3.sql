-- liquibase formatted sql
-- changeset SAMQA:1754373930987 stripComments:false logicalFilePath:BASE_RELEASE\samqa\indexes\employer_divisions_n3.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/indexes/employer_divisions_n3.sql:null:26b9c3107ff38e6177ade88f6da7d844e970d91d:create

create index samqa.employer_divisions_n3 on
    samqa.employer_divisions (
        division_main
    );

