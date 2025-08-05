-- liquibase formatted sql
-- changeset SAMQA:1754374156966 stripComments:false logicalFilePath:BASE_RELEASE\samqa\tables\enterprise_census.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/tables/enterprise_census.sql:null:c392c67da1d9e34b551e69b1b236e713afc45760:create

create table samqa.enterprise_census (
    entity_id        varchar2(100 byte),
    entity_type      varchar2(100 byte),
    census_code      varchar2(1000 byte),
    census_numbers   number(10, 0),
    creation_date    date,
    created_by       varchar2(10 byte),
    last_update_date date,
    last_updated_by  varchar2(10 byte),
    ben_plan_id      number
);

