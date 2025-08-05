-- liquibase formatted sql
-- changeset SAMQA:1754374164337 stripComments:false logicalFilePath:BASE_RELEASE\samqa\tables\website_forms.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/tables/website_forms.sql:null:4de76abd7ed88e87259b959e507c4a16c385b0d4:create

create table samqa.website_forms (
    form_id           number,
    form_name         varchar2(3200 byte),
    file_name         varchar2(3200 byte),
    product_type      varchar2(30 byte),
    company_name      varchar2(30 byte),
    url               varchar2(3200 byte),
    note              varchar2(3200 byte),
    creation_date     date,
    created_by        number,
    last_updated_date date,
    last_updated_by   number,
    section_type      varchar2(255 byte),
    category          varchar2(255 byte),
    form_number       number,
    heading           varchar2(3200 byte)
);

alter table samqa.website_forms add primary key ( form_id )
    using index enable;

