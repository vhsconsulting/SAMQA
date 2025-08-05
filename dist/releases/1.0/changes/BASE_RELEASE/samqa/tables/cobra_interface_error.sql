-- liquibase formatted sql
-- changeset SAMQA:1754374153901 stripComments:false logicalFilePath:BASE_RELEASE\samqa\tables\cobra_interface_error.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/tables/cobra_interface_error.sql:null:f90ac8a8df9837492ad14fe3f93ec53ff10802b9:create

create table samqa.cobra_interface_error (
    interface_err_id number,
    entity_type      varchar2(255 byte),
    entity_id        number,
    entity_key       varchar2(255 byte),
    error_message    varchar2(3200 byte),
    creation_date    date,
    created_by       number
);

alter table samqa.cobra_interface_error add primary key ( interface_err_id )
    using index enable;

