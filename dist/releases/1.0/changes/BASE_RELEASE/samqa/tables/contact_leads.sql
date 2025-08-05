-- liquibase formatted sql
-- changeset SAMQA:1754374154126 stripComments:false logicalFilePath:BASE_RELEASE\samqa\tables\contact_leads.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/tables/contact_leads.sql:null:bde210ce4208d5e38dac71d3ef914397dad658d8:create

create table samqa.contact_leads (
    contact_id      number,
    first_name      varchar2(100 byte),
    email           varchar2(100 byte),
    user_id         number,
    creation_date   date,
    updated         varchar2(1 byte),
    entity_id       varchar2(100 byte),
    account_type    varchar2(100 byte),
    contact_type    varchar2(100 byte),
    send_invoice    varchar2(1 byte),
    entity_type     varchar2(30 byte),
    ref_entity_id   number,
    ref_entity_type varchar2(30 byte),
    phone_num       varchar2(100 byte),
    contact_fax     varchar2(100 byte),
    job_title       varchar2(100 byte),
    lic_number      varchar2(100 byte),
    validity        varchar2(20 byte),
    contact_flg     varchar2(1 byte),
    lic_number_flag varchar2(10 byte),
    prefetched_flg  varchar2(10 byte)
);

