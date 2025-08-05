-- liquibase formatted sql
-- changeset SAMQA:1754374156996 stripComments:false logicalFilePath:BASE_RELEASE\samqa\tables\enterprise_staging.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/tables/enterprise_staging.sql:null:e0631b73716cd1083db0fd84b79d3c6ec5c78c19:create

create table samqa.enterprise_staging (
    entrp_stg_id                number,
    entrp_id                    number,
    en_code                     varchar2(100 byte),
    name                        varchar2(100 byte),
    batch_number                number,
    created_by                  number,
    creation_date               date,
    last_updated_by             number,
    last_update_date            date,
    entity_type                 varchar2(100 byte),
    affliated_entity_type_other varchar2(100 byte),
    affliated_ein               varchar2(100 byte),
    affliated_entity_type       varchar2(100 byte),
    affliated_address           varchar2(100 byte),
    affliated_city              varchar2(30 byte),
    affliated_zip               varchar2(10 byte),
    affliated_state             varchar2(100 byte)
);

