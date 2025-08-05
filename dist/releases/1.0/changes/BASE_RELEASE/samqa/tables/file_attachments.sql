-- liquibase formatted sql
-- changeset SAMQA:1754374158551 stripComments:false logicalFilePath:BASE_RELEASE\samqa\tables\file_attachments.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/tables/file_attachments.sql:null:bc52b3792278a39b8c7c7793ee57793a88087d25:create

create table samqa.file_attachments (
    attachment_id          number,
    document_name          varchar2(3200 byte),
    document_type          varchar2(3200 byte),
    attachment             blob,
    entity_name            varchar2(30 byte),
    entity_id              varchar2(200 byte),
    creation_date          date,
    created_by             number,
    last_update_date       date,
    last_updated_by        number,
    document_purpose       varchar2(100 byte),
    description            varchar2(1000 byte),
    show_online            varchar2(1 byte),
    show_online_employee   varchar2(1 byte) default 'N',
    verified_flag          varchar2(1 byte) default 'N',
    verified_by            number(10, 0),
    submitted_by           varchar2(100 byte),
    paid_by                varchar2(100 byte),
    show_online_broker     varchar2(1 byte),
    uploaded_by            varchar2(100 byte),
    batch_number           number,
    rto_plan_doc_sent_by   varchar2(20 byte),
    rto_plan_doc_sent_date date
);

create index samqa.file_attachments_u1 on
    samqa.file_attachments (
        attachment_id
    );

alter table samqa.file_attachments
    add constraint file_attachments_pk
        primary key ( attachment_id )
            using index samqa.file_attachments_u1 enable;

