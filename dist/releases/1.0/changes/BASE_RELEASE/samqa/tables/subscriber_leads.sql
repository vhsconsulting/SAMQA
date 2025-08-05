-- liquibase formatted sql
-- changeset SAMQA:1754374163409 stripComments:false logicalFilePath:BASE_RELEASE\samqa\tables\subscriber_leads.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/tables/subscriber_leads.sql:null:eb731b07636043f64b523ba789f8e3141b7c3e8d:create

create table samqa.subscriber_leads (
    subscriber_lead_id number,
    salesrep_id        number,
    broker_name        varchar2(300 byte),
    group_name         varchar2(300 byte),
    first_name         varchar2(300 byte),
    last_name          varchar2(300 byte),
    carrier_name       varchar2(300 byte),
    plan_name          varchar2(30 byte),
    setup_fee          number,
    creation_date      date,
    created_by         number,
    last_update_date   date,
    last_updated_by    number
);

create unique index samqa.subscriber_lead_pk on
    samqa.subscriber_leads (
        subscriber_lead_id
    );

alter table samqa.subscriber_leads
    add constraint subscriber_lead_pk
        primary key ( subscriber_lead_id )
            using index samqa.subscriber_lead_pk enable;

