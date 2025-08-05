-- liquibase formatted sql
-- changeset SAMQA:1754374152833 stripComments:false logicalFilePath:BASE_RELEASE\samqa\tables\card_transfer.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/tables/card_transfer.sql:null:8f60e14f90991d564e5f588d624bbcb47cd36ac7:create

create table samqa.card_transfer (
    transfer_id     number(9, 0) not null enable,
    card_id         number(9, 0) not null enable,
    transfer_date   date default trunc(sysdate) not null enable,
    transfer_amount number(15, 2) not null enable,
    note            varchar2(4000 byte),
    cur_bal         number(15, 2)
);

create unique index samqa.card_transfer_pk on
    samqa.card_transfer (
        transfer_id
    );

alter table samqa.card_transfer
    add constraint card_transfer_amount check ( transfer_amount <> 0 ) enable;

alter table samqa.card_transfer
    add constraint card_transfer_pk
        primary key ( transfer_id )
            using index samqa.card_transfer_pk enable;

