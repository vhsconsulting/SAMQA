-- liquibase formatted sql
-- changeset SAMQA:1754374159600 stripComments:false logicalFilePath:BASE_RELEASE\samqa\tables\invest_transfer.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/tables/invest_transfer.sql:null:d1a03ae0c4b911bd1a8eb0758ad469f36732adf8:create

create table samqa.invest_transfer (
    transfer_id      number(9, 0) not null enable,
    investment_id    number(9, 0) not null enable,
    invest_date      date default trunc(sysdate) not null enable,
    invest_amount    number(15, 2) not null enable,
    invest_code      number(3, 0),
    note             varchar2(4000 byte),
    creation_date    date default sysdate,
    created_by       number,
    last_update_date date default sysdate,
    last_updated_by  number,
    claim_id         number(9, 0)
);

create unique index samqa.invest_transfer_pk on
    samqa.invest_transfer (
        transfer_id
    );

alter table samqa.invest_transfer
    add constraint invest_transfer_pk
        primary key ( transfer_id )
            using index samqa.invest_transfer_pk enable;

