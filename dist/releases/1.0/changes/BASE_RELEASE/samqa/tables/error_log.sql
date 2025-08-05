-- liquibase formatted sql
-- changeset SAMQA:1754374158198 stripComments:false logicalFilePath:BASE_RELEASE\samqa\tables\error_log.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/tables/error_log.sql:null:e7af5d58377026369f12a0a6317a4cf76f0d1270:create

create table samqa.error_log (
    error_id      number(5, 0),
    pkg_name      varchar2(2000 byte),
    proc_name     varchar2(2000 byte),
    call_stack    varchar2(4000 byte),
    error_stack   varchar2(4000 byte),
    error_bktrc   varchar2(4000 byte),
    params        varchar2(4000 byte),
    creation_date date default sysdate
);

alter table samqa.error_log add primary key ( error_id )
    using index enable;

