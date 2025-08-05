-- liquibase formatted sql
-- changeset SAMQA:1754373930997 stripComments:false logicalFilePath:BASE_RELEASE\samqa\indexes\employer_divisions_u1.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/indexes/employer_divisions_u1.sql:null:836d649a693a98cd5b89c30652c335f26c80c654:create

create index samqa.employer_divisions_u1 on
    samqa.employer_divisions (
        division_code,
        entrp_id
    );

