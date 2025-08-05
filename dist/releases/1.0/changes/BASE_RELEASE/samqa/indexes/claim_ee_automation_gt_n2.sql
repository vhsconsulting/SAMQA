-- liquibase formatted sql
-- changeset SAMQA:1754373930217 stripComments:false logicalFilePath:BASE_RELEASE\samqa\indexes\claim_ee_automation_gt_n2.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/indexes/claim_ee_automation_gt_n2.sql:null:a96f89cf10652fd166ddd42abce172abb94d6c52:create

create index samqa.claim_ee_automation_gt_n2 on
    samqa.claim_ee_automation_gt (
        claim_id,
        service_type
    );

