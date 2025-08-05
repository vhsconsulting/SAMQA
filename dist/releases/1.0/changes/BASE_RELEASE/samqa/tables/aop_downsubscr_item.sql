-- liquibase formatted sql
-- changeset SAMQA:1754374151507 stripComments:false logicalFilePath:BASE_RELEASE\samqa\tables\aop_downsubscr_item.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/tables/aop_downsubscr_item.sql:null:f79234a09077e1b83875640f10c32c6580371873:create

create table samqa.aop_downsubscr_item (
    id            number not null enable,
    downsubscr_id number not null enable,
    item_name     varchar2(255 byte),
    item_value    clob,
    created       date not null enable,
    created_by    varchar2(255 byte) not null enable,
    updated       date not null enable,
    updated_by    varchar2(255 byte) not null enable
);

alter table samqa.aop_downsubscr_item
    add constraint aop_downsubscr_item_pk primary key ( id )
        using index enable;

