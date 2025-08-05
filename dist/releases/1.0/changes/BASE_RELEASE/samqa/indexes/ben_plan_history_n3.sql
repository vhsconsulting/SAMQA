-- liquibase formatted sql
-- changeset SAMQA:1754373929648 stripComments:false logicalFilePath:BASE_RELEASE\samqa\indexes\ben_plan_history_n3.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/indexes/ben_plan_history_n3.sql:null:32e21452353b3e32d01938fa6414599ac7812b7a:create

create index samqa.ben_plan_history_n3 on
    samqa.ben_plan_history (
        life_event_code
    );

