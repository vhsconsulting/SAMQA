-- liquibase formatted sql
-- changeset SAMQA:1754374177980 stripComments:false logicalFilePath:BASE_RELEASE\samqa\views\payroll_calendar.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/views/payroll_calendar.sql:null:8be3cc4aba869869f8902a9540990b07e988b0f1:create

create or replace force editionable view samqa.payroll_calendar (
    calendar_id,
    entrp_id,
    period_date,
    frequency,
    payment_start_date,
    payment_end_date,
    scheduler_name,
    scheduler_id
) as
    select
        sc.scalendar_id        calendar_id,
        cm.entrp_id,
        sc.period_date,
        sm.recurring_frequency frequency,
        sm.payment_start_date,
        sm.payment_end_date,
        sm.scheduler_name,
        sm.scheduler_id
    from
        scheduler_calendar sc,
        calendar_master    cm,
        scheduler_master   sm
    where
            cm.calendar_id = sm.calendar_id
        and sm.scheduler_id = sc.schedule_id
        and cm.calendar_type = 'PAYROLL_CALENDAR';

