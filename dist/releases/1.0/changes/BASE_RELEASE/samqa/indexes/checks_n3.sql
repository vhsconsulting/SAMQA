-- liquibase formatted sql
-- changeset SAMQA:1754373930050 stripComments:false logicalFilePath:BASE_RELEASE\samqa\indexes\checks_n3.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/indexes/checks_n3.sql:null:b516175474913b94d7ef5aff639852ad42cde7b0:create

create index samqa.checks_n3 on
    samqa.checks (
        entity_id
    );

