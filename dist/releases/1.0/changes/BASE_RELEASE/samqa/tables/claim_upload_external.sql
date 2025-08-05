-- liquibase formatted sql
-- changeset SAMQA:1754374153416 stripComments:false logicalFilePath:BASE_RELEASE\samqa\tables\claim_upload_external.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/tables/claim_upload_external.sql:null:e4e85a3e3e48bdbac3dd97ee6a969f40fc817ac5:create

create table samqa.claim_upload_external (
    record_id                varchar2(30 byte),
    tpa_id                   varchar2(30 byte),
    employee_id              varchar2(30 byte),
    plan_type                varchar2(30 byte),
    trans_date               varchar2(30 byte),
    sequence_number          varchar2(30 byte),
    claim_amount             varchar2(30 byte),
    check_number             varchar2(30 byte),
    check_date               varchar2(30 byte),
    reimbursement_method     varchar2(30 byte),
    partial_auth             varchar2(30 byte),
    partial_authorized       varchar2(30 byte),
    denied_amount            varchar2(30 byte),
    deductible_amount        varchar2(30 byte),
    merchant_name            varchar2(3000 byte),
    transaction_amt          varchar2(30 byte),
    transaction_code         varchar2(30 byte),
    transaction_status       varchar2(30 byte),
    pos_flag                 varchar2(30 byte),
    offset_amt               varchar2(30 byte),
    service_code             varchar2(30 byte),
    servic_desc              varchar2(3200 byte),
    pay_provider             varchar2(30 byte),
    settlement_date          varchar2(30 byte),
    provider_id              varchar2(30 byte),
    transaction_process_code varchar2(30 byte),
    manual_claim_number      varchar2(30 byte),
    pended_amount            varchar2(30 byte),
    user_id                  varchar2(255 byte),
    detail_response_code     varchar2(255 byte),
    last_updated             varchar2(255 byte),
    last_updated_time        varchar2(255 byte),
    tracking_number          varchar2(255 byte)
)
organization external ( type oracle_loader
    default directory claim_dir access parameters (
        records delimited by newline
        fields terminated by ',' optionally enclosed by '"' lrtrim missing field values are null
    ) location ( claim_dir : 'lagunaoaks.csv' )
) reject limit unlimited;

