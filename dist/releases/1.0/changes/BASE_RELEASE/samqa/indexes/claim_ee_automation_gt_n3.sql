-- liquibase formatted sql
-- changeset SAMQA:1754373930224 stripComments:false logicalFilePath:BASE_RELEASE\samqa\indexes\claim_ee_automation_gt_n3.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/indexes/claim_ee_automation_gt_n3.sql:null:8e73fd88ea06124f9a36c6d0c3648b2dcfc3d7a6:create

create index samqa.claim_ee_automation_gt_n3 on
    samqa.claim_ee_automation_gt (
        pers_id
    );

