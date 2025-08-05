-- liquibase formatted sql
-- changeset SAMQA:1754374151528 stripComments:false logicalFilePath:BASE_RELEASE\samqa\tables\aop_downsubscr_log.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/tables/aop_downsubscr_log.sql:null:14c7fa6108d26cca40ce89796a8b377317543530:create

create table samqa.aop_downsubscr_log (
    id                     number not null enable,
    app_id                 number,
    page_id                number,
    region_pipe_report_ids varchar2(4000 byte),
    app_user               varchar2(4000 byte),
    output_filename        varchar2(300 byte),
    output_mime_type       varchar2(250 byte),
    downsubscr_id          number,
    created                date not null enable,
    created_by             varchar2(255 byte) not null enable
);

alter table samqa.aop_downsubscr_log
    add constraint aop_downsubscr_log_pk primary key ( id )
        using index enable;

