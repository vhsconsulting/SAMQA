-- liquibase formatted sql
-- changeset SAMQA:1754373932959 stripComments:false logicalFilePath:BASE_RELEASE\samqa\indexes\plan_notices_n2.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/indexes/plan_notices_n2.sql:null:46f606ba1d4010eb349847b0b46148306ac94125:create

create index samqa.plan_notices_n2 on
    samqa.plan_notices (
        notice_type
    );

