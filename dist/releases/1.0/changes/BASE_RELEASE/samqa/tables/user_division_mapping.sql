-- liquibase formatted sql
-- changeset SAMQA:1754374163915 stripComments:false logicalFilePath:BASE_RELEASE\samqa\tables\user_division_mapping.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/tables/user_division_mapping.sql:null:7055c0bcb5be05673119e746ccf56ece0cf4a0db:create

create table samqa.user_division_mapping (
    user_division_id number,
    user_id          number,
    division_id      number,
    start_date       date,
    end_date         date,
    status           varchar2(1 byte),
    creation_date    date default sysdate,
    created_by       number,
    last_update_date date default sysdate,
    last_updated_by  number
);

alter table samqa.user_division_mapping add primary key ( user_division_id )
    using index enable;

