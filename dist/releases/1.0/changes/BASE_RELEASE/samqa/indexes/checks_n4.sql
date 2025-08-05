-- liquibase formatted sql
-- changeset SAMQA:1754373930050 stripComments:false logicalFilePath:BASE_RELEASE\samqa\indexes\checks_n4.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/indexes/checks_n4.sql:null:64dacd7f83c8e64e40c29daa6ed9102dd1149c90:create

create index samqa.checks_n4 on
    samqa.checks (
        entity_id,
        entity_type
    );

