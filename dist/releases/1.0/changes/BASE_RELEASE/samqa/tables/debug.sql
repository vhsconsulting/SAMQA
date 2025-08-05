-- liquibase formatted sql
-- changeset SAMQA:1754374154678 stripComments:false logicalFilePath:BASE_RELEASE\samqa\tables\debug.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/tables/debug.sql:null:5fefaa13d8d64973622d82be47def971815737c9:create

create table samqa.debug (
    error_time date,
    message    varchar2(2000 byte)
);

