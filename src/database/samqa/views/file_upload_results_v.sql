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


-- sqlcl_snapshot {"hash":"0a1cfee8e5d51211218cb4ead6a32e6e2a699af5","type":"VIEW","name":"FILE_UPLOAD_RESULTS_V","schemaName":"SAMQA","sxml":""}