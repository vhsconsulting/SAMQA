-- liquibase formatted sql
-- changeset SAMQA:1754373929400 stripComments:false logicalFilePath:BASE_RELEASE\samqa\indexes\ben_life_event_history_n4.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/indexes/ben_life_event_history_n4.sql:null:112fc87f70664223e76388d388ac4b142ebc44ef:create

create index samqa.ben_life_event_history_n4 on
    samqa.ben_life_event_history (
        ben_plan_id
    );

