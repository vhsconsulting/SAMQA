-- liquibase formatted sql
-- changeset SAMQA:1754374173580 stripComments:false logicalFilePath:BASE_RELEASE\samqa\views\file_upload_results_v.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/views/file_upload_results_v.sql:null:0a1cfee8e5d51211218cb4ead6a32e6e2a699af5:create

create or replace force editionable view samqa.file_upload_results_v (
    name,
    entrp_id,
    acc_num,
    enrollment_status,
    error_message,
    processed_date,
    file_upload_id
) as
    select
        b.first_name
        || ' '
        || b.last_name                         name,
        a.entrp_id,
        b.acc_num,
        b.enrollment_status,
        b.error_message,
        to_char(b.creation_date, 'MM/DD/YYYY') processed_date,
        file_upload_id
    from
        file_upload_history a,
        online_enrollment   b
    where
            a.entrp_id = b.entrp_id
        and a.batch_number = b.batch_number;

