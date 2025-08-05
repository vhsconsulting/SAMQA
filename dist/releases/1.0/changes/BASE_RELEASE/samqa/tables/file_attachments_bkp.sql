-- liquibase formatted sql
-- changeset SAMQA:1754374158581 stripComments:false logicalFilePath:BASE_RELEASE\samqa\tables\file_attachments_bkp.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/tables/file_attachments_bkp.sql:null:4452f2fa4dc944e23c1d6e9f05a923c6d9d9b97a:create

create table samqa.file_attachments_bkp (
    attachment_id    number,
    document_name    varchar2(3200 byte),
    document_type    varchar2(3200 byte),
    attachment       blob,
    entity_name      varchar2(30 byte),
    entity_id        number,
    creation_date    date,
    created_by       number,
    last_update_date date,
    last_updated_by  number
);

