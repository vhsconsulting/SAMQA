-- liquibase formatted sql
-- changeset SAMQA:1754374152555 stripComments:false logicalFilePath:BASE_RELEASE\samqa\tables\broker.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/tables/broker.sql:null:ccf443295fea7cd046b15c5fb2d799b781fdc233:create

create table samqa.broker (
    broker_id              number(9, 0),
    start_date             date not null enable,
    end_date               date,
    broker_lic             varchar2(20 byte),
    broker_rate            number(5, 2) default 15,
    share_rate             number(5, 2),
    ga_rate                number(5, 2),
    ga_id                  number(9, 0),
    note                   varchar2(4000 byte),
    creation_date          date default sysdate,
    created_by             number,
    last_update_date       date default sysdate,
    last_updated_by        number,
    agency_name            varchar2(100 byte),
    salesrep_id            number,
    verified_by            number,
    verified_date          date,
    commissions_payable_to varchar2(100 byte),
    flg_agree              varchar2(1 byte),
    cheque_flag            varchar2(1 byte) default 'Y',
    reason_flag            varchar2(200 byte),
    am_id                  number
);

create unique index samqa.broker_pk on
    samqa.broker (
        broker_id
    );

create unique index samqa.broker_lic_u on
    samqa.broker (
        broker_lic
    );

alter table samqa.broker
    add constraint broker_end_date check ( end_date >= start_date ) enable;

alter table samqa.broker
    add constraint broker_lic_u unique ( broker_lic )
        using index samqa.broker_lic_u enable;

alter table samqa.broker
    add constraint broker_pk
        primary key ( broker_id )
            using index samqa.broker_pk enable;

