-- liquibase formatted sql
-- changeset SAMQA:1754374161630 stripComments:false logicalFilePath:BASE_RELEASE\samqa\tables\online_users_bkp.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/tables/online_users_bkp.sql:null:a925b0ad34e95d0bd6a056a1323e343f04e56b13:create

create table samqa.online_users_bkp (
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
    email            varchar2(40 byte),
    pw_question      varchar2(250 byte),
    pw_answer        varchar2(255 byte),
    user_id          number,
    confirmed_flag   varchar2(1 byte),
    creation_date    date,
    last_update_date date
);

