-- liquibase formatted sql
-- changeset SAMQA:1754374152602 stripComments:false logicalFilePath:BASE_RELEASE\samqa\tables\broker_assignments.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/tables/broker_assignments.sql:null:b9118b90b4d0c38e2bcb5200a5b86ae9ddecf1c8:create

create table samqa.broker_assignments (
    broker_assignment_id number,
    broker_id            number not null enable,
    pers_id              number,
    entrp_id             number,
    effective_date       date,
    creation_date        date default sysdate not null enable,
    created_by           number not null enable,
    last_update_date     date default sysdate not null enable,
    last_updated_by      number not null enable,
    status               varchar2(1 byte) default 'A',
    effective_end_date   date default null
);

