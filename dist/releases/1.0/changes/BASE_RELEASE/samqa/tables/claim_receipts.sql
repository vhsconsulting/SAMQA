-- liquibase formatted sql
-- changeset SAMQA:1754374153368 stripComments:false logicalFilePath:BASE_RELEASE\samqa\tables\claim_receipts.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/tables/claim_receipts.sql:null:b277f7e632abc87b76a1a36041635ba5387d8fc6:create

create table samqa.claim_receipts (
    batch_num        number,
    acc_id           number,
    receipt_id       number,
    receipt_name     varchar2(300 byte),
    receipt_doc      blob,
    file_type        varchar2(10 byte),
    mime_type        varchar2(500 byte),
    user_id          number,
    creation_date    date,
    created_by       number,
    last_update_date date,
    last_updated_by  number
);

