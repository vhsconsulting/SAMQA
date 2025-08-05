-- liquibase formatted sql
-- changeset SAMQA:1754374155744 stripComments:false logicalFilePath:BASE_RELEASE\samqa\tables\directory_list.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/tables/directory_list.sql:null:c99bd480a6f41fdaa3abba348917b8dca5168d93:create

create global temporary table samqa.directory_list (
    file_id      number,
    filename     varchar2(255 byte),
    lastmodified date
) on commit preserve rows;

