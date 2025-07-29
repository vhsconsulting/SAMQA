create or replace force editionable view samqa.file_upload_history_v (
    upload_date,
    entrp_id,
    file_name,
    file_upload_result,
    file_upload_id,
    process_type,
    no_of_employees
) as
    select
        to_char(a.creation_date, 'MM/DD/YYYY') upload_date,
        a.entrp_id,
        file_name,
        file_upload_result,
        a.file_upload_id,
        b.process_type,    -- added for 7919 by rprabu on 12/08/2019
        count(*)                               no_of_employees
    from
        file_upload_history a,
        online_enrollment   b
    where
            a.entrp_id = b.entrp_id
        and a.batch_number = b.batch_number
    group by
        to_char(a.creation_date, 'MM/DD/YYYY'),
        a.entrp_id,
        file_name,
        file_upload_result,
        a.file_upload_id,
        b.process_type 		-- added for 7919 by rprabu on 12/08/2019
    order by
        a.file_upload_id desc;


-- sqlcl_snapshot {"hash":"23624aeed36e231a6e1718ca8a31780f6fe84c3e","type":"VIEW","name":"FILE_UPLOAD_HISTORY_V","schemaName":"SAMQA","sxml":""}