-- liquibase formatted sql
-- changeset SAMQA:1754374163941 stripComments:false logicalFilePath:BASE_RELEASE\samqa\tables\user_external.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/tables/user_external.sql:null:7a3e8ea2de6151d3c06fed9c81cf014d7a6fcf86:create

create table samqa.user_external (
    user_name    varchar2(12 byte),
    password     varchar2(25 byte),
    user_type    varchar2(1 byte),
    emp_reg_type varchar2(1 byte),
    find_key     varchar2(15 byte),
    locked_time  varchar2(30 byte),
    succ_access  number,
    last_login   varchar2(30 byte),
    failed_att   number,
    failed_ip    varchar2(30 byte),
    create_pw    varchar2(30 byte),
    change_pw    varchar2(30 byte),
    email        varchar2(40 byte),
    pw_question  varchar2(250 byte),
    pw_answer    varchar2(50 byte)
)
organization external ( type oracle_loader
    default directory online_enroll_dir access parameters (
        records delimited by newline
        fields terminated by '~' optionally enclosed by '"' missing field values are null
    ) location ( 'Online_User.csv' )
) reject limit unlimited;

