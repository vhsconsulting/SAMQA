-- liquibase formatted sql
-- changeset SAMQA:1754374162025 stripComments:false logicalFilePath:BASE_RELEASE\samqa\tables\payroll_calendar_bkp.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/tables/payroll_calendar_bkp.sql:null:f458af810aaacb878fa58fd0ccd3e0fedc3cd099:create

create table samqa.payroll_calendar_bkp (
    calendar_id      number,
    entrp_id         number,
    period_date      date,
    creation_date    date,
    created_by       number,
    last_update_date date,
    last_updated_by  number,
    frequency        varchar2(255 byte),
    division_code    varchar2(255 byte)
);

