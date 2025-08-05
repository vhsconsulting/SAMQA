-- liquibase formatted sql
-- changeset SAMQA:1754373930146 stripComments:false logicalFilePath:BASE_RELEASE\samqa\indexes\claim_automation_gt_n1.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/indexes/claim_automation_gt_n1.sql:null:b1131e268ec20a629ed20f6605d77d7b4b3a7787:create

create index samqa.claim_automation_gt_n1 on
    samqa.claim_automation_gt (
        status
    );

