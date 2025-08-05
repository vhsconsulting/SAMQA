-- liquibase formatted sql
-- changeset SAMQA:1754374162944 stripComments:false logicalFilePath:BASE_RELEASE\samqa\tables\sam_users.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/tables/sam_users.sql:null:135718bae82eebb88b95775aa8787dc15fc3ee06:create

create table samqa.sam_users (
    user_id            number,
    user_name          varchar2(100 byte),
    password           varchar2(4000 byte),
    expires_on         date,
    created_on         date default sysdate,
    role_id            number,
    last_activity_date date,
    status             varchar2(1 byte) default 'A',
    failed_logins      number,
    logout_date        date,
    creation_date      date default sysdate,
    last_update_date   date default sysdate,
    last_updated_by    number,
    created_by         number,
    contract_user      varchar2(1 byte) default 'N'
);

create unique index samqa.sam_users_pk on
    samqa.sam_users (
        user_id
    );

alter table samqa.sam_users
    add constraint sam_users_pk
        primary key ( user_id )
            using index samqa.sam_users_pk enable;

