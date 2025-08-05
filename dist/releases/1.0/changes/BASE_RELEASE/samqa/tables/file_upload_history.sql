-- liquibase formatted sql
-- changeset SAMQA:1754374158627 stripComments:false logicalFilePath:BASE_RELEASE\samqa\tables\file_upload_history.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/tables/file_upload_history.sql:null:fc444c5529b9d173944287ac263f44545329a6be:create

create table samqa.file_upload_history (
    file_upload_id     number,
    entrp_id           number,
    broker_id          number,
    batch_number       varchar2(3200 byte),
    file_name          varchar2(3200 byte),
    file_upload_result varchar2(3200 byte),
    creation_date      date default sysdate not null enable,
    created_by         number default 421 not null enable,
    last_update_date   date default sysdate not null enable,
    last_updated_by    number default 421 not null enable,
    action             varchar2(30 byte) default 'ENROLLMENT',
    account_type       varchar2(30 byte),
    enrollment_source  varchar2(100 byte),
    file_type          varchar2(100 byte),
    no_of_employees    number
);

alter table samqa.file_upload_history add primary key ( file_upload_id )
    using index enable;

