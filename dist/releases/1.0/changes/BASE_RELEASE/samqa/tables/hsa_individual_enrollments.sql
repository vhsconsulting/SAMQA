-- liquibase formatted sql
-- changeset SAMQA:1754374159338 stripComments:false logicalFilePath:BASE_RELEASE\samqa\tables\hsa_individual_enrollments.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/tables/hsa_individual_enrollments.sql:null:8a838108982d30cd32a889fafbcd303b8e9a5631:create

create table samqa.hsa_individual_enrollments (
    enrollments       number,
    terminations      number,
    active            number,
    suspended         number,
    period_start_date date,
    period_end_date   date,
    creation_date     date,
    created_by        number,
    last_update_date  date,
    last_updated_by   number
);

