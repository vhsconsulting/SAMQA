-- liquibase formatted sql
-- changeset SAMQA:1754373932269 stripComments:false logicalFilePath:BASE_RELEASE\samqa\indexes\notes_idx4.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/indexes/notes_idx4.sql:null:d7fb546fcc5351cc6b58ea73b6c9b35207d8c7c0:create

create index samqa.notes_idx4 on
    samqa.notes (
        entrp_id
    );

