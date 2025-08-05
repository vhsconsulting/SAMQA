-- liquibase formatted sql
-- changeset SAMQA:1754374160512 stripComments:false logicalFilePath:BASE_RELEASE\samqa\tables\mcc_codes.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/tables/mcc_codes.sql:null:44b504a254c614e4faa03198cf7bedfdf917b521:create

create table samqa.mcc_codes (
    mcc_code          varchar2(30 byte),
    mcc_description   varchar2(1000 byte),
    irs_description   varchar2(1000 byte),
    irs_reportable    varchar2(1 byte),
    irs_special_notes varchar2(1000 byte),
    creation_date     date default sysdate,
    last_update_date  date default sysdate
);

alter table samqa.mcc_codes add primary key ( mcc_code )
    using index enable;

