-- liquibase formatted sql
-- changeset SAMQA:1754373929657 stripComments:false logicalFilePath:BASE_RELEASE\samqa\indexes\ben_plan_history_n4.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/indexes/ben_plan_history_n4.sql:null:f63ea0a25c7aadfe1217a34a277ede748330e879:create

create index samqa.ben_plan_history_n4 on
    samqa.ben_plan_history (
        acc_id
    );

