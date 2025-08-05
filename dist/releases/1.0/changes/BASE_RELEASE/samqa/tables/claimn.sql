-- liquibase formatted sql
-- changeset SAMQA:1754374153461 stripComments:false logicalFilePath:BASE_RELEASE\samqa\tables\claimn.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/tables/claimn.sql:null:adde1f09236f19ace4c09fc9134b9664944cbb92:create

create table samqa.claimn (
    claim_id                number(9, 0) not null enable,
    pers_id                 number(9, 0) not null enable,
    pers_patient            number(9, 0) not null enable,
    claim_code              varchar2(50 byte),
    prov_name               varchar2(100 byte),
    claim_date_start        date not null enable,
    claim_date_end          date,
    tax_code                varchar2(20 byte),
    service_status          number(3, 0),
    claim_amount            number(15, 2) not null enable,
    claim_paid              number(15, 2),
    claim_pending           number(15, 2),
    note                    varchar2(4000 byte),
    ineligible_amount       number,
    denied_amount           number,
    denied_reason           varchar2(255 byte),
    reimbursement_method    varchar2(30 byte),
    claim_status            varchar2(30 byte),
    mcc_code                varchar2(30 byte),
    service_start_date      date,
    service_end_date        date,
    service_type            varchar2(30 byte),
    reviewed_date           date,
    doc_flag                varchar2(1 byte),
    expense_category        varchar2(255 byte),
    insurance_category      varchar2(255 byte),
    approved_amount         number,
    entrp_id                number,
    approved_date           date,
    deductible_amount       number,
    plan_start_date         date,
    plan_end_date           date,
    released_date           date,
    released_by             number,
    reviewed_by             number,
    payment_release_date    date,
    payment_released_by     number,
    funds_availability_date date,
    takeover                varchar2(1 byte) default 'N',
    benefits_received_date  date,
    bank_acct_id            number,
    vendor_id               number,
    pay_reason              number,
    claim_date              date,
    creation_date           date default sysdate,
    created_by              number,
    last_update_date        date default sysdate,
    last_updated_by         number,
    source_claim_id         number,
    offset_amount           number(15, 2),
    substantiation_reason   varchar2(20 byte),
    unsubstantiated_flag    varchar2(2 byte),
    doc_offset_amt          number(15, 2),
    claim_source            varchar2(30 byte) default 'INTERNAL',
    future_claim_offset     number,
    trans_fraud_flag        varchar2(1 byte) default 'N'
);

create unique index samqa.claimn_pk on
    samqa.claimn (
        claim_id
    );

alter table samqa.claimn
    add constraint claimn_date_end check ( claim_date_end >= claim_date_start ) disable;

alter table samqa.claimn
    add constraint claimn_pk
        primary key ( claim_id )
            using index samqa.claimn_pk enable;

