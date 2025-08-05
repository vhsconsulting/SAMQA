-- liquibase formatted sql
-- changeset SAMQA:1754373930175 stripComments:false logicalFilePath:BASE_RELEASE\samqa\indexes\claim_automation_gt_n3.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/indexes/claim_automation_gt_n3.sql:null:2343cc12cf961f5ca47d44c94161ef38e3cf9066:create

create index samqa.claim_automation_gt_n3 on
    samqa.claim_automation_gt (
        claim_id
    );

