-- liquibase formatted sql
-- changeset SAMQA:1754374151572 stripComments:false logicalFilePath:BASE_RELEASE\samqa\tables\aop_downsubscr_output.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/tables/aop_downsubscr_output.sql:null:660427ff054f5416b1e965f5629c4c86a699e4ea:create

create table samqa.aop_downsubscr_output (
    id               number not null enable,
    app_id           number,
    page_id          number,
    app_user         varchar2(4000 byte),
    downsubscr_id    number,
    output_filename  varchar2(300 byte),
    output_blob      blob,
    output_mime_type varchar2(250 byte),
    created          date not null enable,
    created_by       varchar2(255 byte) not null enable
);

alter table samqa.aop_downsubscr_output
    add constraint aop_downsubscr_output_pk primary key ( id )
        using index enable;

