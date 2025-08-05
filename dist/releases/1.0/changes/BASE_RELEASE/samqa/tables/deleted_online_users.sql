-- liquibase formatted sql
-- changeset SAMQA:1754374155623 stripComments:false logicalFilePath:BASE_RELEASE\samqa\tables\deleted_online_users.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/tables/deleted_online_users.sql:null:33515567fae6e1f5cf995417107e488168df689e:create

create table samqa.deleted_online_users (
    user_name        varchar2(12 byte),
    password         varchar2(25 byte),
    user_type        varchar2(1 byte),
    emp_reg_type     varchar2(1 byte),
    find_key         varchar2(15 byte),
    locked_time      varchar2(30 byte),
    succ_access      number,
    last_login       varchar2(30 byte),
    failed_att       number,
    failed_ip        varchar2(30 byte),
    create_pw        varchar2(30 byte),
    change_pw        varchar2(30 byte),
    email            varchar2(155 byte),
    pw_question      varchar2(250 byte),
    pw_answer        varchar2(255 byte),
    user_id          number,
    confirmed_flag   varchar2(1 byte),
    creation_date    date,
    last_update_date date,
    blocked          varchar2(1 byte),
    tax_id           varchar2(30 byte),
    user_status      varchar2(1 byte),
    reactivated_date date
);

