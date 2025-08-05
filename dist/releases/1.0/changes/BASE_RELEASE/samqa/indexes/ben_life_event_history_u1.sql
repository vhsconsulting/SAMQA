-- liquibase formatted sql
-- changeset SAMQA:1754373929408 stripComments:false logicalFilePath:BASE_RELEASE\samqa\indexes\ben_life_event_history_u1.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/indexes/ben_life_event_history_u1.sql:null:c471d78fac128b50ec30b13d58f1417dfe85b4ab:create

create index samqa.ben_life_event_history_u1 on
    samqa.ben_life_event_history (
        life_event_id
    );

