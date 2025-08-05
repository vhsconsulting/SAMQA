-- liquibase formatted sql
-- changeset SAMQA:1754374161585 stripComments:false logicalFilePath:BASE_RELEASE\samqa\tables\online_user_security_history.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/tables/online_user_security_history.sql:null:617188c8bc04b683997fae36320bda43b51df038:create

create table samqa.online_user_security_history (
    change_id          number,
    pers_id            number,
    user_id            number,
    email              varchar2(100 byte),
    phone_no           varchar2(30 byte),
    created_by         number,
    creation_date      date,
    new_email_phone_no varchar2(155 byte)
);

