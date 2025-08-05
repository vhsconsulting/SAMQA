-- liquibase formatted sql
-- changeset SAMQA:1754374151245 stripComments:false logicalFilePath:BASE_RELEASE\samqa\tables\acn_employee_migration.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/tables/acn_employee_migration.sql:null:7a616eb9f5ee81e8a8c1d2a72e98027fe0b2d84a:create

create table samqa.acn_employee_migration (
    mig_seq_no      number,
    acc_id          number,
    pers_id         number,
    first_name      varchar2(255 byte),
    middle_name     varchar2(255 byte),
    last_name       varchar2(255 byte),
    gender          varchar2(30 byte),
    ssn             varchar2(30 byte),
    birth_date      varchar2(30 byte),
    address1        varchar2(255 byte),
    address2        varchar2(255 byte),
    city            varchar2(255 byte),
    state           varchar2(30 byte),
    zip             varchar2(30 byte),
    email_address   varchar2(100 byte),
    user_name       varchar2(100 byte),
    pw_question     varchar2(250 byte),
    pw_answer       varchar2(255 byte),
    emp_acc_id      number,
    phone_day       varchar2(100 byte),
    phone_even      varchar2(100 byte),
    account_type    varchar2(20 byte),
    action_type     varchar2(1 byte),
    subscriber_type varchar2(1 byte),
    process_status  varchar2(30 byte),
    error_message   varchar2(3200 byte),
    creation_date   date,
    created_by      number
);

