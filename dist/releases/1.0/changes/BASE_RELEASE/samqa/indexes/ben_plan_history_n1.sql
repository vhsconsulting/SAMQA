-- liquibase formatted sql
-- changeset SAMQA:1754373929622 stripComments:false logicalFilePath:BASE_RELEASE\samqa\indexes\ben_plan_history_n1.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/indexes/ben_plan_history_n1.sql:null:b614d93c1dc1bf3bba7b443ae5af7ac699eab55e:create

create index samqa.ben_plan_history_n1 on
    samqa.ben_plan_history (
        ben_plan_id
    );

