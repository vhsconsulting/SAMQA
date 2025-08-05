-- liquibase formatted sql
-- changeset SAMQA:1754374175902 stripComments:false logicalFilePath:BASE_RELEASE\samqa\views\hrafsa_file_upload_results_v.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/views/hrafsa_file_upload_results_v.sql:null:f87f0ba3bb8e8d928df0e0b8e042a1f7195898d6:create

create or replace force editionable view samqa.hrafsa_file_upload_results_v (
    name,
    entrp_id,
    acc_num,
    enrollment_status,
    plan_type,
    error_message,
    processed_date,
    file_upload_id,
    batch_number,
    process_type
) as
    select
        b.first_name
        || ' '
        || b.last_name                         name,
        a.entrp_id,
        b.acc_num,
        b.enrollment_status,
        c.plan_type,
        nvl(c.status, b.error_message)         error_message,
        to_char(b.creation_date, 'MM/DD/YYYY') processed_date,
        file_upload_id,
        a.batch_number,
        b.process_type   ---- RPRABU PROCESS_TYPE  ADDED FOR 7792 02/08/2019
    from
        file_upload_history a,
        online_enrollment   b,
        online_enroll_plans c
    where
            a.entrp_id = b.entrp_id
        and a.batch_number = b.batch_number
        and b.enrollment_id = c.enrollment_id (+);

