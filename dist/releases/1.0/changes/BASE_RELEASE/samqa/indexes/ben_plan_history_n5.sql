-- liquibase formatted sql
-- changeset SAMQA:1754373929667 stripComments:false logicalFilePath:BASE_RELEASE\samqa\indexes\ben_plan_history_n5.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/indexes/ben_plan_history_n5.sql:null:e6875acdd04d79ccdfb77234cfbf6dcf5449f990:create

create index samqa.ben_plan_history_n5 on
    samqa.ben_plan_history (
        plan_start_date,
        plan_end_date
    );

