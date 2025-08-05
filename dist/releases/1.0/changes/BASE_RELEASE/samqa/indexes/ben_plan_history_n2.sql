-- liquibase formatted sql
-- changeset SAMQA:1754373929636 stripComments:false logicalFilePath:BASE_RELEASE\samqa\indexes\ben_plan_history_n2.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/indexes/ben_plan_history_n2.sql:null:66fe95893e6ef98fe1060b61fcecfb74eab5f61e:create

create index samqa.ben_plan_history_n2 on
    samqa.ben_plan_history (
        plan_type
    );

