-- liquibase formatted sql
-- changeset SAMQA:1754373930233 stripComments:false logicalFilePath:BASE_RELEASE\samqa\indexes\claim_ee_automation_gt_n4.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/indexes/claim_ee_automation_gt_n4.sql:null:dd0635a46f0c8568393ad03435089ed8e6685e0c:create

create index samqa.claim_ee_automation_gt_n4 on
    samqa.claim_ee_automation_gt (
        entrp_id
    );

