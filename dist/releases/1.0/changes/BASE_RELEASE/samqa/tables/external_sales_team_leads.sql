-- liquibase formatted sql
-- changeset SAMQA:1754374158299 stripComments:false logicalFilePath:BASE_RELEASE\samqa\tables\external_sales_team_leads.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/tables/external_sales_team_leads.sql:null:ad669294ee0c97f289347e429e2be32adde827c1:create

create table samqa.external_sales_team_leads (
    external_sales_team_id number not null enable,
    first_name             varchar2(255 byte),
    last_name              varchar2(255 byte),
    license                varchar2(255 byte),
    agency_name            varchar2(2000 byte),
    tax_id                 varchar2(255 byte),
    gender                 varchar2(255 byte),
    address                varchar2(255 byte),
    city                   varchar2(255 byte),
    state                  varchar2(255 byte),
    zip                    varchar2(255 byte),
    phone1                 varchar2(255 byte),
    phone2                 varchar2(255 byte),
    email                  varchar2(255 byte),
    creation_date          date default sysdate,
    entrp_id               number,
    ref_entity_id          number,
    ref_entity_type        varchar2(255 byte),
    lead_source            varchar2(255 byte),
    entity_type            varchar2(255 byte)
);

alter table samqa.external_sales_team_leads add primary key ( external_sales_team_id )
    using index enable;

