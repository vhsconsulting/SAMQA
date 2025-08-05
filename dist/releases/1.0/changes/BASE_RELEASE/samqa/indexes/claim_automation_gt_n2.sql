-- liquibase formatted sql
-- changeset SAMQA:1754373930158 stripComments:false logicalFilePath:BASE_RELEASE\samqa\indexes\claim_automation_gt_n2.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/indexes/claim_automation_gt_n2.sql:null:edd01d1f730e1b9ceb55f57f0dbf6371cab4eb5b:create

create index samqa.claim_automation_gt_n2 on
    samqa.claim_automation_gt (
        entrp_id
    );

