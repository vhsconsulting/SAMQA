-- liquibase formatted sql
-- changeset SAMQA:1754374152707 stripComments:false logicalFilePath:BASE_RELEASE\samqa\tables\calendar_master.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/tables/calendar_master.sql:null:aee6538511c56fb2123ccaa5da953fc6c984807d:create

create table samqa.calendar_master (
    calendar_id      number,
    calendar_type    varchar2(255 byte),
    entrp_id         number,
    creation_date    date default sysdate,
    created_by       number,
    last_update_date date default sysdate,
    last_updated_by  number,
    division_code    varchar2(255 byte)
);

alter table samqa.calendar_master add primary key ( calendar_id )
    using index enable;

