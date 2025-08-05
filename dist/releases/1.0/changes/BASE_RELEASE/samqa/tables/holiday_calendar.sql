-- liquibase formatted sql
-- changeset SAMQA:1754374159283 stripComments:false logicalFilePath:BASE_RELEASE\samqa\tables\holiday_calendar.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/tables/holiday_calendar.sql:null:5b9e3bc5702ed438658dd8c08512c90480dd52ce:create

create table samqa.holiday_calendar (
    calendar_id      number,
    acc_id           number,
    holiday_date     date,
    description      varchar2(3200 byte),
    creation_date    date,
    created_by       number,
    last_update_date date,
    last_updated_by  number
);

