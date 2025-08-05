-- liquibase formatted sql
-- changeset SAMQA:1754374159989 stripComments:false logicalFilePath:BASE_RELEASE\samqa\tables\letter_templates.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/tables/letter_templates.sql:null:84463b214ebfe97674507636812273b0f7aa15ab:create

create table samqa.letter_templates (
    template_id         number,
    template_type       varchar2(255 byte),
    template_code       varchar2(255 byte),
    template_name       varchar2(255 byte),
    created_by          number,
    creation_date       date,
    last_updated_by     number,
    last_update_date    date,
    account_type        varchar2(30 byte) default 'HSA',
    lang_pref           varchar2(30 byte) default 'ENGLISH',
    entrp_id            number,
    letter_source       varchar2(30 byte),
    email_template_name varchar2(30 byte),
    event               varchar2(30 byte),
    description         varchar2(255 byte)
);

