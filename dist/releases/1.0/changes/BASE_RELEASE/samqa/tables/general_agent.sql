-- liquibase formatted sql
-- changeset SAMQA:1754374158908 stripComments:false logicalFilePath:BASE_RELEASE\samqa\tables\general_agent.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/tables/general_agent.sql:null:7e0582610c916ada6f48ae2686ffd0e03cf18591:create

create table samqa.general_agent (
    ga_id                  number(9, 0),
    agency_name            varchar2(100 byte),
    address                varchar2(2000 byte),
    city                   varchar2(255 byte),
    state                  varchar2(255 byte),
    zip                    varchar2(255 byte),
    phone                  varchar2(255 byte),
    email                  varchar2(255 byte),
    start_date             date not null enable,
    end_date               date,
    ga_lic                 varchar2(20 byte),
    ga_rate                number(5, 2),
    note                   varchar2(4000 byte),
    creation_date          date default sysdate,
    created_by             number,
    last_update_date       date default sysdate,
    last_updated_by        number,
    salesrep_id            number,
    contact_name           varchar2(100 byte),
    flg_agree              varchar2(1 byte),
    generate_combined_stmt varchar2(1 byte) default 'N'
);

alter table samqa.general_agent
    add constraint ga_end_date check ( end_date >= start_date ) enable;

alter table samqa.general_agent add primary key ( ga_id )
    using index enable;

alter table samqa.general_agent add unique ( ga_lic )
    using index enable;

