-- liquibase formatted sql
-- changeset SAMQA:1754373930208 stripComments:false logicalFilePath:BASE_RELEASE\samqa\indexes\claim_ee_automation_gt_n1.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/indexes/claim_ee_automation_gt_n1.sql:null:5765a7cbb0f49ff72095add659ed765f402494e3:create

create index samqa.claim_ee_automation_gt_n1 on
    samqa.claim_ee_automation_gt (
        claim_id
    );

