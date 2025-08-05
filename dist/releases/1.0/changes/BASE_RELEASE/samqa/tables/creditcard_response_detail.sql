-- liquibase formatted sql
-- changeset SAMQA:1754374154216 stripComments:false logicalFilePath:BASE_RELEASE\samqa\tables\creditcard_response_detail.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/tables/creditcard_response_detail.sql:null:9b234b52ed31a72a8b5cb7ae2be92a80467af67c:create

create table samqa.creditcard_response_detail (
    document_id      number not null enable,
    document_name    varchar2(255 byte),
    document_data    clob,
    document_source  varchar2(255 byte),
    document_type    varchar2(255 byte),
    processed_flag   varchar2(1 byte),
    batch_number     number,
    process_message  varchar2(255 byte),
    creation_date    date,
    created_by       number,
    last_update_date date,
    last_updated_by  number
);

