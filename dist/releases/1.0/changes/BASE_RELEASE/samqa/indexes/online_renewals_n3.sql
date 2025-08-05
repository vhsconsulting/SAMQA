-- liquibase formatted sql
-- changeset SAMQA:1754373932530 stripComments:false logicalFilePath:BASE_RELEASE\samqa\indexes\online_renewals_n3.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/indexes/online_renewals_n3.sql:null:e2cf2679a64d650c7318b66543b5a2a444bb3a20:create

create index samqa.online_renewals_n3 on
    samqa.online_renewals (
        ben_plan_id
    );

