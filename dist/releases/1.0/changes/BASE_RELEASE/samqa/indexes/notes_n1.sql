-- liquibase formatted sql
-- changeset SAMQA:1754373932305 stripComments:false logicalFilePath:BASE_RELEASE\samqa\indexes\notes_n1.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/indexes/notes_n1.sql:null:1db707da8148b244d3ef3423e8f1174e40d04c1b:create

create index samqa.notes_n1 on
    samqa.notes (
        entity_id
    );

