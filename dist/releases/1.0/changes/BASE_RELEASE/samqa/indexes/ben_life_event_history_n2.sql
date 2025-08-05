-- liquibase formatted sql
-- changeset SAMQA:1754373929385 stripComments:false logicalFilePath:BASE_RELEASE\samqa\indexes\ben_life_event_history_n2.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/indexes/ben_life_event_history_n2.sql:null:43533f8b23b2a48513a301f063f7321a7856f378:create

create index samqa.ben_life_event_history_n2 on
    samqa.ben_life_event_history (
        acc_id
    );

