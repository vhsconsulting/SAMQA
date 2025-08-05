-- liquibase formatted sql
-- changeset SAMQA:1754374153299 stripComments:false logicalFilePath:BASE_RELEASE\samqa\tables\claim_ee_automation_gt.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/tables/claim_ee_automation_gt.sql:null:d791bc08d2a0386aec8af27aff42c89acbbefd09:create

create global temporary table samqa.claim_ee_automation_gt (
    claim_id         number,
    plan_start_date  date,
    plan_end_date    date,
    service_type     varchar2(30 byte),
    acc_id           number,
    pers_id          number,
    entrp_id         number,
    acc_num          varchar2(30 byte),
    product_type     varchar2(30 byte),
    ee_balance       number,
    pending_amount   number,
    claim_to_be_paid number,
    invoice_id       number,
    processed_inv    number,
    funding_options  varchar2(30 byte),
    to_be_processed  varchar2(1 byte)
) on commit delete rows;

