-- liquibase formatted sql
-- changeset SAMQA:1754374162865 stripComments:false logicalFilePath:BASE_RELEASE\samqa\tables\sales_team_member.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/tables/sales_team_member.sql:null:2151f382839c114f7e6cf28e80b2a991e94f95d9:create

create table samqa.sales_team_member (
    sales_team_member_id number,
    entity_type          varchar2(255 byte),
    entity_id            number,
    mem_role             varchar2(255 byte),
    emplr_id             number,
    start_date           date default sysdate,
    end_date             date,
    status               varchar2(1 byte) default 'A',
    creation_date        date,
    created_by           number,
    last_update_date     date,
    last_updated_by      number,
    pay_commission       varchar2(10 byte),
    notes                varchar2(3200 byte),
    no_of_days           number(3, 0)
);

alter table samqa.sales_team_member
    add constraint start_dt_ck check ( start_date is not null ) disable;

alter table samqa.sales_team_member add primary key ( sales_team_member_id )
    using index enable;

