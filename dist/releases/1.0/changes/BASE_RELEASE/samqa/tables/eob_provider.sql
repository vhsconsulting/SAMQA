-- liquibase formatted sql
-- changeset SAMQA:1754374157704 stripComments:false logicalFilePath:BASE_RELEASE\samqa\tables\eob_provider.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/tables/eob_provider.sql:null:01ae135a27687ae730f83b1cdf2fc4fbb2a81dad:create

create table samqa.eob_provider (
    eob_provider_id  number,
    provider_name    varchar2(255 byte),
    address          varchar2(255 byte),
    city             varchar2(255 byte),
    state            varchar2(255 byte),
    zip              varchar2(255 byte),
    tax_id           varchar2(255 byte),
    provider_npi     varchar2(255 byte),
    user_id          number,
    vendor_id        number,
    acc_id           number,
    source           varchar2(255 byte),
    creation_date    date,
    last_update_date date,
    last_updated_by  number,
    created_by       number,
    address2         varchar2(255 byte),
    address1         varchar2(255 byte),
    payee_nick_name  varchar2(20 byte)
);

