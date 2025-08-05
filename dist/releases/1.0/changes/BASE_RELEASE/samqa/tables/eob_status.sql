-- liquibase formatted sql
-- changeset SAMQA:1754374157721 stripComments:false logicalFilePath:BASE_RELEASE\samqa\tables\eob_status.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/tables/eob_status.sql:null:be6e134607ffc5c79959c220c96b8c5e11d19ffb:create

create table samqa.eob_status (
    user_id          varchar2(100 byte),
    account_id       varchar2(100 byte),
    action           varchar2(100 byte),
    carrier_name     varchar2(3200 byte),
    carrier_id       varchar2(100 byte),
    user_name        varchar2(100 byte),
    password         varchar2(100 byte),
    status_id        varchar2(100 byte),
    status_message   varchar2(3200 byte),
    member_id        varchar2(100 byte),
    created_on       varchar2(100 byte),
    last_updated_on  varchar2(100 byte),
    creation_date    date default sysdate,
    last_update_date date default sysdate
);

