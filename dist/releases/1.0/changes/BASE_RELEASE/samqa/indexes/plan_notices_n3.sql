-- liquibase formatted sql
-- changeset SAMQA:1753779556606 stripComments:false logicalFilePath:BASE_RELEASE\samqa\indexes\plan_notices_n3.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/indexes/plan_notices_n3.sql:null:270679d619f8a732dbd2faac44513740c59aeb52:create

create index samqa.plan_notices_n3 on
    samqa.plan_notices (
        test_result
    );

