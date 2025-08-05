-- liquibase formatted sql
-- changeset SAMQA:1754374152053 stripComments:false logicalFilePath:BASE_RELEASE\samqa\tables\batch_jobs_result_log.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/tables/batch_jobs_result_log.sql:null:1c0a86f40ca80a47dbe7781dc5efa9e05878af4a:create

create table samqa.batch_jobs_result_log (
    batch_log_id   number,
    job_name       varchar2(250 byte),
    error_code     number,
    error_message  varchar2(4000 byte),
    component_info clob,
    creation_date  date,
    start_date     date,
    end_date       date
);

