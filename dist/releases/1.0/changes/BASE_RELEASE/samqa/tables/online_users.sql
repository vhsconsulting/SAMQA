-- liquibase formatted sql
-- changeset SAMQA:1754374161610 stripComments:false logicalFilePath:BASE_RELEASE\samqa\tables\online_users.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/tables/online_users.sql:null:792071fe80ee50c55f65507186e998628609b575:create

create table samqa.online_users (
    user_name            varchar2(24 byte),
    password             varchar2(50 byte),
    user_type            varchar2(1 byte),
    emp_reg_type         varchar2(1 byte),
    find_key             varchar2(15 byte),
    locked_time          varchar2(30 byte),
    succ_access          number,
    last_login           varchar2(30 byte),
    failed_att           number,
    failed_ip            varchar2(30 byte),
    create_pw            varchar2(30 byte),
    change_pw            varchar2(30 byte),
    email                varchar2(155 byte),
    pw_question          varchar2(250 byte),
    pw_answer            varchar2(255 byte),
    user_id              number,
    confirmed_flag       varchar2(1 byte) default 'N',
    creation_date        date default sysdate,
    last_update_date     date default sysdate,
    blocked              varchar2(1 byte) default 'N',
    tax_id               varchar2(30 byte),
    user_status          varchar2(1 byte) default 'A',
    reactivated_date     date,
    first_time_pw_flag   varchar2(1 byte),
    security_setup_grace date,
    skip_security        varchar2(1 byte),
    created_by           number,
    last_updated_by      number,
    locked_reason        varchar2(30 byte),
    sso_user             varchar2(1 byte) default 'N',
    last_login_ip        varchar2(30 byte)
);

