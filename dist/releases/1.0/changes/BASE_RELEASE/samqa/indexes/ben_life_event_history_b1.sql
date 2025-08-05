-- liquibase formatted sql
-- changeset SAMQA:1754373929378 stripComments:false logicalFilePath:BASE_RELEASE\samqa\indexes\ben_life_event_history_b1.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/indexes/ben_life_event_history_b1.sql:null:730452d71c0fee49bc4ca74c64b9743e9cb93e9f:create

create index samqa.ben_life_event_history_b1 on
    samqa.ben_life_event_history (
        acc_num
    );

