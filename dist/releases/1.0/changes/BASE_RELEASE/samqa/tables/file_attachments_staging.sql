-- liquibase formatted sql
-- changeset SAMQA:1754374158598 stripComments:false logicalFilePath:BASE_RELEASE\samqa\tables\file_attachments_staging.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/tables/file_attachments_staging.sql:null:9c61aa0580e6916b6ecd1c2d6d0bade6b68fe211:create

create table samqa.file_attachments_staging (
    attachment_id         number,
    document_name         varchar2(3200 byte),
    document_type         varchar2(3200 byte),
    attachment            blob,
    entity_name           varchar2(30 byte),
    creation_date         date,
    created_by            number,
    last_update_date      date,
    last_updated_by       number,
    document_purpose      varchar2(100 byte),
    description           varchar2(1000 byte),
    show_online           varchar2(1 byte),
    plan_id               number,
    entrp_id              number(9, 0),
    batch_number          number,
    user_bank_acct_stg_id number
);

