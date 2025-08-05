-- liquibase formatted sql
-- changeset SAMQA:1754374151384 stripComments:false logicalFilePath:BASE_RELEASE\samqa\tables\agile_payment_access.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/tables/agile_payment_access.sql:null:62b4d5f728ea0a5feee46ecfc80b34b568089bf8:create

create table samqa.agile_payment_access (
    api_access_id   varchar2(255 byte),
    api_secure_key  varchar2(255 byte),
    organization_id number,
    location_id     number,
    account_type    varchar2(30 byte),
    status          varchar2(255 byte),
    api_url         varchar2(1000 byte),
    effective_date  date default sysdate,
    creation_date   date default sysdate,
    env_owner       varchar2(30 byte)
);

