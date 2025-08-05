-- liquibase formatted sql
-- changeset SAMQA:1754374152804 stripComments:false logicalFilePath:BASE_RELEASE\samqa\tables\card_debit.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/tables/card_debit.sql:null:0cd56cad9b935b65c2fc24f5b75f9bed6d15319b:create

create table samqa.card_debit (
    card_id             number(9, 0) not null enable,
    start_date          date default ( trunc(sysdate, 'YYYY') ),
    end_date            date,
    emitent             number(9, 0),
    note                varchar2(4000 byte),
    status              number,
    card_num            varchar2(30 byte),
    max_card_value      number(15, 2) default 500,
    current_card_value  number(15, 2),
    new_card_value      number(15, 2),
    bal_adjust_value    number(15, 2),
    current_bal_value   number(15, 2),
    current_auth_value  number(15, 2),
    old_card_value      number(15, 2),
    terminated          char(1 byte) default 'N',
    last_update_date    date,
    issue_date          varchar2(30 byte),
    mailed_date         varchar2(30 byte),
    activation_date     varchar2(30 byte),
    expire_date         varchar2(30 byte),
    card_number         varchar2(30 byte),
    status_code         varchar2(30 byte),
    tracking_number     varchar2(30 byte),
    created_by          number,
    last_updated_by     number,
    issue_conditional   varchar2(30 byte),
    pin_mailer          varchar2(1 byte),
    mailer_request_date date,
    shipping_method     number
);

create unique index samqa.card_debit_pk on
    samqa.card_debit (
        card_id
    );

alter table samqa.card_debit
    add constraint card_debit_pk
        primary key ( card_id )
            using index samqa.card_debit_pk enable;

