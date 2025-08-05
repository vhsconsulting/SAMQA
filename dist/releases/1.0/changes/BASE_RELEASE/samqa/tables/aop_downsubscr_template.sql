-- liquibase formatted sql
-- changeset SAMQA:1754374151598 stripComments:false logicalFilePath:BASE_RELEASE\samqa\tables\aop_downsubscr_template.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/tables/aop_downsubscr_template.sql:null:ccbd4decac6619f069011149251662ac0ad35d78:create

create table samqa.aop_downsubscr_template (
    id               number not null enable,
    title            varchar2(255 byte) not null enable,
    description      clob,
    template_blob    blob,
    template_url     varchar2(255 byte),
    file_name        varchar2(255 byte),
    mime_type        varchar2(255 byte),
    last_update_date date,
    template_default number(3, 0) default 0,
    report_types     varchar2(255 byte),
    created          date not null enable,
    created_by       varchar2(255 byte) not null enable,
    updated          date not null enable,
    updated_by       varchar2(255 byte) not null enable
);

alter table samqa.aop_downsubscr_template
    add constraint aop_downsubscr_template_pk primary key ( id )
        using index enable;

