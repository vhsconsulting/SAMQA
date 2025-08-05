-- liquibase formatted sql
-- changeset SAMQA:1754374151486 stripComments:false logicalFilePath:BASE_RELEASE\samqa\tables\aop_downsubscr.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/tables/aop_downsubscr.sql:null:ddfbea45954b10a51adea8d87d439c386e3977ae:create

create table samqa.aop_downsubscr (
    id                     number not null enable,
    app_id                 number,
    page_id                number,
    region_pipe_report_ids varchar2(4000 byte),
    items_in_session       varchar2(4000 byte),
    app_user               varchar2(4000 byte),
    template_type          varchar2(100 byte),
    template_source        clob,
    output_type            varchar2(4000 byte),
    output_to              varchar2(100 byte),
    output_procedure       varchar2(100 byte),
    start_date             timestamp(6) with local time zone,
    end_date               timestamp(6) with local time zone,
    repeat_every           number,
    repeat_interval        varchar2(100 byte),
    repeat_days            varchar2(100 byte),
    repeat_string          varchar2(255 byte),
    email_from             varchar2(4000 byte),
    email_to               varchar2(4000 byte),
    email_cc               varchar2(4000 byte),
    email_bcc              varchar2(4000 byte),
    email_subject          varchar2(4000 byte),
    email_body_text        clob,
    email_body_html        clob,
    comments               varchar2(4000 byte),
    job_name               varchar2(4000 byte),
    init_code              clob,
    email_download_link    varchar2(4000 byte),
    email_blob_size        number,
    save_log               varchar2(1 byte),
    created                date not null enable,
    created_by             varchar2(255 byte) not null enable,
    updated                date not null enable,
    updated_by             varchar2(255 byte) not null enable
);

alter table samqa.aop_downsubscr
    add constraint aop_downsubscr_pk primary key ( id )
        using index enable;

