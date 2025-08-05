-- liquibase formatted sql
-- changeset SAMQA:1754374168564 stripComments:false logicalFilePath:BASE_RELEASE\samqa\views\batch_upload_results_v.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/views/batch_upload_results_v.sql:null:9e151789f7058e53e8d9c53ede8524dd046a7338:create

create or replace force editionable view samqa.batch_upload_results_v (
    name,
    entrp_id,
    acc_num,
    ssn,
    enrollment_status,
    error_message,
    processed_date,
    batch_number
) as
    select
        b.first_name
        || ' '
        || b.last_name                         name,
        b.entrp_id,
        b.acc_num,
        b.ssn,
        b.enrollment_status,
        b.error_message,
        to_char(b.creation_date, 'MM/DD/YYYY') processed_date,
        batch_number
    from
        online_enrollment b
    where
        batch_number is not null;

