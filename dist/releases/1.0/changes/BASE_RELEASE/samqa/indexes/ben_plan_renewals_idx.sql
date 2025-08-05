-- liquibase formatted sql
-- changeset SAMQA:1754373929682 stripComments:false logicalFilePath:BASE_RELEASE\samqa\indexes\ben_plan_renewals_idx.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/indexes/ben_plan_renewals_idx.sql:null:a154205ec236f7f46887280df9eb31ede4bd6c35:create

create index samqa.ben_plan_renewals_idx on
    samqa.ben_plan_renewals (
        ben_plan_id
    );

