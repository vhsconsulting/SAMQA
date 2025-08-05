-- liquibase formatted sql
-- changeset SAMQA:1754374162976 stripComments:false logicalFilePath:BASE_RELEASE\samqa\tables\scheduler_calendar.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/tables/scheduler_calendar.sql:null:75f662ad75210d97be92c3bf4909f6c335646187:create

create table samqa.scheduler_calendar (
    scalendar_id     number,
    schedule_id      number,
    period_date      date,
    creation_date    date default sysdate,
    created_by       number default 0,
    last_update_date date default sysdate,
    last_updated_by  number default 0
);

alter table samqa.scheduler_calendar add primary key ( scalendar_id )
    using index enable;

