-- liquibase formatted sql
-- changeset SAMQA:1754373930066 stripComments:false logicalFilePath:BASE_RELEASE\samqa\indexes\checks_n6.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/indexes/checks_n6.sql:null:cdb8908623b6554ac2db64f51e22879638e52cb4:create

create index samqa.checks_n6 on
    samqa.checks (
        status,
        entity_type,
        source_system
    );

