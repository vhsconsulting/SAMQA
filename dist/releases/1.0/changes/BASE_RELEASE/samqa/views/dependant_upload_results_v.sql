-- liquibase formatted sql
-- changeset SAMQA:1754374171529 stripComments:false logicalFilePath:BASE_RELEASE\samqa\views\dependant_upload_results_v.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/views/dependant_upload_results_v.sql:null:f9eb6e952dd4b291343ebf144ab25eaae949e525:create

create or replace force editionable view samqa.dependant_upload_results_v (
    name,
    entrp_id,
    ssn,
    beneficiary_type,
    error_message,
    processed_date,
    file_upload_id,
    batch_number
) as
    select
        b.first_name
        || ' '
        || b.last_name                         name,
        a.entrp_id,
        b.ssn,
        b.beneficiary_type,
        b.error_message,
        to_char(b.creation_date, 'MM/DD/YYYY') processed_date,
        file_upload_id,
        a.batch_number
    from
        file_upload_history   a,
        mass_enroll_dependant b
    where
            a.entrp_id = b.entrp_acc_id
        and a.batch_number = b.batch_number;

