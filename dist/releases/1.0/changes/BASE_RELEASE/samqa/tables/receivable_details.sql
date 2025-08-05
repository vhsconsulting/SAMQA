-- liquibase formatted sql
-- changeset SAMQA:1754374162604 stripComments:false logicalFilePath:BASE_RELEASE\samqa\tables\receivable_details.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/tables/receivable_details.sql:null:75438bd3dee8cce899d96cdfb863b1ad075abc00:create

create table samqa.receivable_details (
    receivable_det_id number,
    receivable_id     number,
    group_acc_id      number,
    acc_id            number,
    amount            number,
    transaction_date  date,
    status            varchar2(255 byte),
    note              varchar2(3200 byte),
    creation_date     date default sysdate,
    created_by        number,
    last_update_date  date default sysdate,
    last_updated_by   number,
    group_number      varchar2(30 byte),
    member_number     varchar2(30 byte),
    quantity          number,
    line_amount       number,
    rate_code         varchar2(30 byte),
    returned_amount   number,
    cancelled_amount  number
);

alter table samqa.receivable_details add primary key ( receivable_det_id )
    using index enable;

