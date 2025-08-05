-- liquibase formatted sql
-- changeset SAMQA:1754374158276 stripComments:false logicalFilePath:BASE_RELEASE\samqa\tables\external_files.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/tables/external_files.sql:null:ce8e49a6eb866c23224b39199a4ca5e28dbd499c:create

create table samqa.external_files (
    file_id          number,
    file_action      varchar2(30 byte),
    file_name        varchar2(320 byte),
    result_flag      varchar2(1 byte),
    creation_date    date,
    last_update_date date,
    sent_flag        varchar2(1 byte),
    error_message    varchar2(1000 byte),
    description      varchar2(2000 byte)
);

