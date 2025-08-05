-- liquibase formatted sql
-- changeset SAMQA:1754374151451 stripComments:false logicalFilePath:BASE_RELEASE\samqa\tables\aop_config.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/tables/aop_config.sql:null:3729b6c89aff268994965a8310a9a47572ef0be6:create

create table samqa.aop_config (
    id                 number not null enable,
    aop_url            varchar2(200 byte) not null enable,
    api_key            varchar2(50 byte),
    aop_mode           varchar2(15 byte),
    failover_aop_url   varchar2(200 byte),
    failover_procedure varchar2(200 byte),
    debug              varchar2(10 byte),
    converter          varchar2(100 byte),
    settings_pkg       varchar2(100 byte),
    logging_pkg        varchar2(100 byte),
    email_from         varchar2(200 byte),
    created            date not null enable,
    created_by         varchar2(255 byte) not null enable,
    updated            date not null enable,
    updated_by         varchar2(255 byte) not null enable
);

alter table samqa.aop_config
    add constraint aop_config_pk primary key ( id )
        using index enable;

