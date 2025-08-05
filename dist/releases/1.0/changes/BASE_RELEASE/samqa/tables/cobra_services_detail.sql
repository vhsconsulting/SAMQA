-- liquibase formatted sql
-- changeset SAMQA:1754374153986 stripComments:false logicalFilePath:BASE_RELEASE\samqa\tables\cobra_services_detail.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/tables/cobra_services_detail.sql:null:be0ee16d84aee724dba5c15d76055fecc5db989e:create

create table samqa.cobra_services_detail (
    acc_id            number,
    ben_plan_id       number,
    service_type      varchar2(50 byte),
    service_selected  varchar2(1 byte),
    created_by        number,
    creation_date     date,
    last_updated_by   number,
    last_updated_date date,
    effective_date    date
);

