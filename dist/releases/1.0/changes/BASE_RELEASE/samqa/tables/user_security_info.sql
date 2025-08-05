-- liquibase formatted sql
-- changeset SAMQA:1754374164010 stripComments:false logicalFilePath:BASE_RELEASE\samqa\tables\user_security_info.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/tables/user_security_info.sql:null:f06a149d1f2c32909b7ba92ff280324173d085ad:create

create table samqa.user_security_info (
    user_id               number,
    site_key              varchar2(100 byte),
    site_image            number,
    pw_question1          number,
    pw_answer1            varchar2(255 byte),
    pw_question2          number,
    pw_answer2            varchar2(255 byte),
    pw_question3          number,
    pw_answer3            varchar2(255 byte),
    remember_pc           varchar2(1 byte) default 'N',
    creation_date         date default sysdate,
    created_by            number,
    last_update_date      date default sysdate,
    last_updated_by       number,
    otp_verified          varchar2(1 byte),
    otp_verified_time     date,
    verified_phone_number varchar2(30 byte),
    verified_phone_type   varchar2(30 byte),
    verified_email        varchar2(100 byte),
    skip_date             date,
    phone_update_date     date
);

create unique index samqa.user_security_info_u1 on
    samqa.user_security_info (
        user_id
    );

alter table samqa.user_security_info
    add
        primary key ( user_id )
            using index samqa.user_security_info_u1 enable;

