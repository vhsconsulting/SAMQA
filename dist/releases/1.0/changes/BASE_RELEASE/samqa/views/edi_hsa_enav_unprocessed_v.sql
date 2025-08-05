-- liquibase formatted sql
-- changeset SAMQA:1754374171645 stripComments:false logicalFilePath:BASE_RELEASE\samqa\views\edi_hsa_enav_unprocessed_v.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/views/edi_hsa_enav_unprocessed_v.sql:null:97f3fca6135a9a871347c7cac70ab6ae50d53b37:create

create or replace force editionable view samqa.edi_hsa_enav_unprocessed_v (
    tax_id,
    ssn,
    first_name,
    middle_name,
    last_name,
    gender,
    birth_date,
    address1,
    address2,
    city,
    state,
    zip,
    phone,
    email,
    plan_type,
    hsa_plan_type,
    effective_date,
    termination_date,
    document_id,
    batch_number
) as
    select
        enroll_data.tax_id,
        enroll_data.ssn,
        enroll_data.first_name,
        enroll_data.middle_name,
        enroll_data.last_name,
        enroll_data.gender,
        enroll_data.birth_date,
        enroll_data.address1,
        enroll_data.address2,
        enroll_data.city,
        enroll_data.state,
        enroll_data.zip,
        enroll_data.phone,
        enroll_data.email,
        enroll_data.plan_type,
        enroll_data.hsa_plan_type,
        enroll_data.effective_date,
        enroll_data.termination_date,
        document_id,
        batch_number
    from
        (
            select
                document_id,
                batch_number,
                document_data,
                processed_flag
            from
                edi_enrollment_documents
            where
                document_type like 'EE_FILE_UPLOAD_HSA%'
                and processed_flag = 'N'
        ) enrollment_documents,
        json_table ( enrollment_documents.document_data, '$[*]'
                columns (
                    tax_id varchar2 ( 100 ) path '$.CompanyIdentifier',
                    ssn varchar2 ( 100 ) path '$.SSN',
                    first_name varchar2 ( 255 ) path '$.FirstName',
                    middle_name varchar2 ( 255 ) path '$.MiddleName',
                    last_name varchar2 ( 100 ) path '$.LastName',
                    gender varchar2 ( 255 ) path '$.Gender',
                    birth_date varchar2 ( 255 ) path '$.birth_date',
                    address1 varchar2 ( 255 ) path '$.Address1',
                    address2 varchar2 ( 255 ) path '$.Address2',
                    city varchar2 ( 255 ) path '$.City',
                    state varchar2 ( 255 ) path '$.State',
                    zip varchar2 ( 255 ) path '$.ZIP',
                    phone varchar2 ( 255 ) path '$.Phone',
                    email varchar2 ( 255 ) path '$.Email',
                    plan_type varchar2 ( 255 ) path '$.plan_type',
                    hsa_plan_type varchar2 ( 255 ) path '$.hsa_plan_type',
                    effective_date varchar2 ( 255 ) path '$.effective_date',
                    termination_date varchar2 ( 255 ) path '$.termination_date'
                )
            )
        as enroll_data;

