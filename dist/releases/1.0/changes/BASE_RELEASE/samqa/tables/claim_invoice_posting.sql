-- liquibase formatted sql
-- changeset SAMQA:1754374153349 stripComments:false logicalFilePath:BASE_RELEASE\samqa\tables\claim_invoice_posting.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/tables/claim_invoice_posting.sql:null:35b5e4426a066a2c86d5d694b3b1c946a86bf448:create

create table samqa.claim_invoice_posting (
    invoice_posting_id  number,
    invoice_id          number,
    claim_id            number,
    payment_amount      number,
    change_num          number,
    transaction_id      number,
    paid_amount         number,
    payment_status      varchar2(30 byte),
    posting_status      varchar2(30 byte),
    pay_date            date,
    creation_date       date,
    created_by          number,
    last_update_date    date,
    last_updated_by     number,
    employer_payment_id number
);

alter table samqa.claim_invoice_posting add primary key ( invoice_posting_id )
    using index enable;

