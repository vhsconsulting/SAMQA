-- liquibase formatted sql
-- changeset SAMQA:1754373929393 stripComments:false logicalFilePath:BASE_RELEASE\samqa\indexes\ben_life_event_history_n3.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/indexes/ben_life_event_history_n3.sql:null:4c4ddb05e9389e22d9104fc79c5ac47546bf5932:create

create index samqa.ben_life_event_history_n3 on
    samqa.ben_life_event_history (
        entrp_id
    );

