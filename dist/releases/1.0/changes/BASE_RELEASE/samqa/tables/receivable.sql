-- liquibase formatted sql
-- changeset SAMQA:1754374162579 stripComments:false logicalFilePath:BASE_RELEASE\samqa\tables\receivable.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/tables/receivable.sql:null:a04abae4030a3cf2b3d8f4cf33344829d8e4e1d3:create

create table samqa.receivable (
    receivable_id       number,
    acc_id              number,
    source_system       varchar2(255 byte),
    source_type         varchar2(255 byte),
    amount_applied      number,
    amount              number,
    start_date          date,
    end_date            date,
    invoice_id          number,
    invoice_date        date,
    invoice_posted_date date,
    applied_date        date,
    accounted_date      date,
    cancelled_date      date,
    gl_date             date,
    gl_posted_date      date,
    status              varchar2(255 byte),
    note                varchar2(3200 byte),
    creation_date       date default sysdate,
    created_by          number,
    last_update_date    date default sysdate,
    last_updated_by     number,
    batch_number        varchar2(30 byte),
    group_number        varchar2(30 byte),
    member_number       varchar2(30 byte),
    payment_batch_id    number,
    cancel_reason       varchar2(30 byte),
    cancelled_by        varchar2(30 byte),
    entrp_id            number,
    returned_amount     number,
    remaining_amount    number,
    cancelled_amount    number
);

alter table samqa.receivable add primary key ( receivable_id )
    using index enable;

