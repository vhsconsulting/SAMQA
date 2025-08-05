-- liquibase formatted sql
-- changeset SAMQA:1754374155830 stripComments:false logicalFilePath:BASE_RELEASE\samqa\tables\edi_enrollment_documents.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/tables/edi_enrollment_documents.sql:null:deaba08327e59d28e04a0e9ae9da1739104bfca4:create

create table samqa.edi_enrollment_documents (
    document_id            number,
    document_name          varchar2(255 byte),
    document_data          clob,
    document_source        varchar2(255 byte),
    document_type          varchar2(255 byte),
    creation_date          date default sysdate,
    created_by             number,
    processed_flag         varchar2(1 byte) default 'N',
    batch_number           number,
    csv_data               clob,
    document_received_date date,
    process_message        varchar2(255 byte),
    remote_file_id         number,
    last_update_date       date,
    last_updated_by        number
);

alter table samqa.edi_enrollment_documents add primary key ( document_id )
    using index enable;

