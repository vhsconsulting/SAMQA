-- liquibase formatted sql
-- changeset SAMQA:1754374163959 stripComments:false logicalFilePath:BASE_RELEASE\samqa\tables\user_login_history.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/tables/user_login_history.sql:null:7b4d522ecb1a6297ae075138a9e5600f292ef4a5:create

create table samqa.user_login_history (
    user_id       number,
    user_name     varchar2(255 byte),
    login_date    date,
    logout_date   date,
    creation_date date
);

