-- liquibase formatted sql
-- changeset SAMQA:1754374156404 stripComments:false logicalFilePath:BASE_RELEASE\samqa\tables\employer_payment_detail_prod.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/tables/employer_payment_detail_prod.sql:null:9ea809f263f6f0b43beddfaddcc67ab14d9ab3e7:create

create table samqa.employer_payment_detail_prod (
    entrp_id            number,
    pay_amount          number,
    check_num           varchar2(22 byte),
    reason_code         number(3, 0) not null enable,
    paid_date           date,
    service_type        varchar2(30 byte),
    plan_start_date     date,
    plan_end_date       date,
    change_num          number,
    employer_payment_id number,
    creation_date       date,
    last_updated_date   date,
    payment_notes       varchar2(3200 byte),
    status              varchar2(3200 byte),
    claim_id            number,
    transaction_id      number,
    check_number        varchar2(30 byte),
    transaction_source  varchar2(30 byte),
    created_date        date default sysdate,
    product_type        varchar2(30 byte)
);

