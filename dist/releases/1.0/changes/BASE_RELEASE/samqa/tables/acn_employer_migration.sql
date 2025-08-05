-- liquibase formatted sql
-- changeset SAMQA:1754374151261 stripComments:false logicalFilePath:BASE_RELEASE\samqa\tables\acn_employer_migration.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/tables/acn_employer_migration.sql:null:d319eb26a271031050b7acf05d557a5dd85538b8:create

create table samqa.acn_employer_migration (
    company_name     varchar2(100 byte),
    entrp_code       varchar2(20 byte),
    address          varchar2(100 byte),
    city             varchar2(30 byte),
    state            varchar2(2 byte),
    zip              varchar2(10 byte),
    first_name       varchar2(4000 byte),
    last_name        varchar2(4000 byte),
    gender           varchar2(1 byte),
    entrp_phones     varchar2(100 byte),
    entrp_email      varchar2(100 byte),
    batch_number     number,
    acc_num          varchar2(20 byte),
    process_status   varchar2(1 byte),
    error_message    varchar2(4000 byte),
    acc_id           number(9, 0),
    account_type     varchar2(30 byte),
    action_type      varchar2(1 byte),
    entrp_id         number(9, 0),
    entrp_fax        varchar2(30 byte),
    creation_date    date,
    created_by       number,
    last_update_date date,
    last_updated_by  number
);

