-- liquibase formatted sql
-- changeset SAMQA:1754373930240 stripComments:false logicalFilePath:BASE_RELEASE\samqa\indexes\claim_ee_automation_gt_n5.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/indexes/claim_ee_automation_gt_n5.sql:null:e8c25362c86249c921fa528d06b815e7ca248714:create

create index samqa.claim_ee_automation_gt_n5 on
    samqa.claim_ee_automation_gt (
        ee_balance
    );

