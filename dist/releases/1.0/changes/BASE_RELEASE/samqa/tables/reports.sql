-- liquibase formatted sql
-- changeset SAMQA:1754374162625 stripComments:false logicalFilePath:BASE_RELEASE\samqa\tables\reports.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/tables/reports.sql:null:75fbb58c713a025b0773893ec228bece00ae38cc:create

create table samqa.reports (
    report_id          number,
    report_name        varchar2(255 byte),
    report_dir         varchar2(255 byte),
    creation_date      date default sysdate,
    file_name          varchar2(255 byte),
    report_action      varchar2(255 byte),
    report_description varchar2(4000 byte)
);

alter table samqa.reports add primary key ( report_id )
    using index enable;

