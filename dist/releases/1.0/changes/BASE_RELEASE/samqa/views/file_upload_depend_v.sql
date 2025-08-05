-- liquibase formatted sql
-- changeset SAMQA:1754374173548 stripComments:false logicalFilePath:BASE_RELEASE\samqa\views\file_upload_depend_v.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/views/file_upload_depend_v.sql:null:65e5a764954786cb24d5e1af9f5e2113b9257b3f:create

create or replace force editionable view samqa.file_upload_depend_v (
    upload_date,
    entrp_id,
    file_name,
    file_upload_result,
    file_upload_id,
    no_of_employees
) as
    select
        to_char(a.creation_date, 'MM/DD/YYYY') upload_date,
        a.entrp_id,
        file_name,
        file_upload_result,
        a.file_upload_id,
        count(*)                               no_of_employees
    from
        file_upload_history   a,
        mass_enroll_dependant b
    where
            a.entrp_id = b.entrp_acc_id
        and a.batch_number = b.batch_number
    group by
        to_char(a.creation_date, 'MM/DD/YYYY'),
        a.entrp_id,
        file_name,
        file_upload_result,
        a.file_upload_id
    order by
        a.file_upload_id desc;

