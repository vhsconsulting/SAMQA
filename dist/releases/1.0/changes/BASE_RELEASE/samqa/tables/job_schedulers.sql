-- liquibase formatted sql
-- changeset SAMQA:1754374159968 stripComments:false logicalFilePath:BASE_RELEASE\samqa\tables\job_schedulers.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/tables/job_schedulers.sql:null:17b6b3c097745585e190d02ba6fc45bda24708ed:create

create table samqa.job_schedulers (
    scheduler_type  varchar2(100 byte),
    job_name        varchar2(100 byte),
    job_type        varchar2(100 byte),
    start_date      date,
    repeat_interval varchar2(500 byte),
    job_action      varchar2(500 byte),
    comments        varchar2(1000 byte)
);

alter table samqa.job_schedulers add primary key ( job_name )
    using index enable;

