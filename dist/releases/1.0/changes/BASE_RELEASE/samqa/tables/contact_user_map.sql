-- liquibase formatted sql
-- changeset SAMQA:1754374154192 stripComments:false logicalFilePath:BASE_RELEASE\samqa\tables\contact_user_map.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/tables/contact_user_map.sql:null:2e16e55851808f3dacc365ada4864330a3d20f46:create

create table samqa.contact_user_map (
    contact_user_id  number,
    contact_id       number,
    user_id          number,
    creation_date    date default sysdate,
    created_by       number,
    last_update_date date default sysdate,
    last_updated_by  number
);

alter table samqa.contact_user_map add primary key ( contact_user_id )
    using index enable;

