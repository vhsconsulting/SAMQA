-- liquibase formatted sql
-- changeset SAMQA:1754373932322 stripComments:false logicalFilePath:BASE_RELEASE\samqa\indexes\notes_n2.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/indexes/notes_n2.sql:null:50490b906282da82693ac980cf8acee2108fe1d2:create

create index samqa.notes_n2 on
    samqa.notes (
        entity_type
    );

