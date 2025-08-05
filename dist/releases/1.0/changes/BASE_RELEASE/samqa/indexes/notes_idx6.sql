-- liquibase formatted sql
-- changeset SAMQA:1754373932290 stripComments:false logicalFilePath:BASE_RELEASE\samqa\indexes\notes_idx6.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/indexes/notes_idx6.sql:null:41c79182e8bf9721f06eb1c23409f1fca0f50f91:create

create index samqa.notes_idx6 on
    samqa.notes (
        acc_id
    );

