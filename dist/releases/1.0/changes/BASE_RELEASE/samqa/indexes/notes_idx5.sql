-- liquibase formatted sql
-- changeset SAMQA:1754373932276 stripComments:false logicalFilePath:BASE_RELEASE\samqa\indexes\notes_idx5.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/indexes/notes_idx5.sql:null:d12a761a8573ca3fd7d971c5c957ccfbd856dee2:create

create index samqa.notes_idx5 on
    samqa.notes (
        pers_id
    );

