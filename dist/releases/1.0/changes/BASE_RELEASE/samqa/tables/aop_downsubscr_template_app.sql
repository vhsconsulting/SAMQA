-- liquibase formatted sql
-- changeset SAMQA:1754374151620 stripComments:false logicalFilePath:BASE_RELEASE\samqa\tables\aop_downsubscr_template_app.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/tables/aop_downsubscr_template_app.sql:null:ab7b1f72e9e4776ace96fa99a58a4001acda7945:create

create table samqa.aop_downsubscr_template_app (
    id                     number not null enable,
    downsubscr_template_id number not null enable,
    app_id                 number,
    page_id                number,
    region_id              number,
    template_default       number(3, 0),
    created                date not null enable,
    created_by             varchar2(255 byte) not null enable,
    updated                date not null enable,
    updated_by             varchar2(255 byte) not null enable
);

alter table samqa.aop_downsubscr_template_app
    add constraint aop_downsubscr_template_app_pk primary key ( id )
        using index enable;

