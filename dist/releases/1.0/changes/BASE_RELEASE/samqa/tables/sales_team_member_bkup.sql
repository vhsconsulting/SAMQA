-- liquibase formatted sql
-- changeset SAMQA:1754374162896 stripComments:false logicalFilePath:BASE_RELEASE\samqa\tables\sales_team_member_bkup.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/tables/sales_team_member_bkup.sql:null:b2fd6527ea3339127ecdde88630336544271209f:create

create table samqa.sales_team_member_bkup (
    sales_team_member_id number,
    entity_type          varchar2(255 byte),
    entity_id            number,
    mem_role             varchar2(255 byte),
    emplr_id             number,
    start_date           date,
    end_date             date,
    status               varchar2(1 byte),
    creation_date        date,
    created_by           number,
    last_update_date     date,
    last_updated_by      number,
    pay_commission       varchar2(10 byte),
    notes                varchar2(3200 byte),
    no_of_days           number(3, 0)
);

