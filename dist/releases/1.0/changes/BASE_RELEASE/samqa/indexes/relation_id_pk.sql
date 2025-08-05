-- liquibase formatted sql
-- changeset SAMQA:1754373933186 stripComments:false logicalFilePath:BASE_RELEASE\samqa\indexes\relation_id_pk.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/indexes/relation_id_pk.sql:null:5b00fcb7d27289344885c7e0d2cd356c757514de:create

create unique index samqa.relation_id_pk on
    samqa.entrp_relationships_staging (
        relation_id
    );

