-- liquibase formatted sql
-- changeset SAMQA:1754374153103 stripComments:false logicalFilePath:BASE_RELEASE\samqa\tables\claim_automation_gt.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/tables/claim_automation_gt.sql:null:b8cecd625499a1344b199086167cef6d564f5547:create

create global temporary table samqa.claim_automation_gt (
    claim_id     number,
    status       varchar2(30 byte),
    entrp_id     number,
    claim_amount number,
    er_balanace  number
) on commit delete rows;

