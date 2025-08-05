-- liquibase formatted sql
-- changeset SAMQA:1754374163983 stripComments:false logicalFilePath:BASE_RELEASE\samqa\tables\user_role_entries.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/tables/user_role_entries.sql:null:9e67ae34c472cd188c650d8ff169f4377d5ade40:create

create table samqa.user_role_entries (
    role_entry_id    number,
    user_id          number,
    site_nav_id      number,
    role_id          number,
    start_date       date,
    end_date         date,
    status           varchar2(1 byte),
    creation_date    date default sysdate,
    created_by       number,
    last_update_date date default sysdate,
    last_updated_by  number,
    authorize_req_id number
);

alter table samqa.user_role_entries add primary key ( role_entry_id )
    using index enable;

