-- liquibase formatted sql
-- changeset SAMQA:1754373930969 stripComments:false logicalFilePath:BASE_RELEASE\samqa\indexes\employer_divisions_n1.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/indexes/employer_divisions_n1.sql:null:a2fec01b1d4554f297eeedec3b06d2d6fba6ee05:create

create index samqa.employer_divisions_n1 on
    samqa.employer_divisions (
        division_code
    );

