-- liquibase formatted sql
-- changeset SAMQA:1754374162992 stripComments:false logicalFilePath:BASE_RELEASE\samqa\tables\scheduler_calendar_stage.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/tables/scheduler_calendar_stage.sql:null:3955fe3eec86b7627d1b344a643253fae79499d8:create

create table samqa.scheduler_calendar_stage (
    batch_number     number,
    period_date      date,
    creation_date    date,
    created_by       number,
    last_update_date date,
    last_updated_by  number
);

