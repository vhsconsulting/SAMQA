-- liquibase formatted sql
-- changeset SAMQA:1754374152687 stripComments:false logicalFilePath:BASE_RELEASE\samqa\tables\broker_salesrep_assignment.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/tables/broker_salesrep_assignment.sql:null:2c6f545a5ec8b70170d320308c1f910555827027:create

create table samqa.broker_salesrep_assignment (
    brk_salesrep_assign_id number not null enable,
    broker_id              number,
    salesrep_id            number,
    effective_date         date,
    effective_end_date     date,
    status                 varchar2(1 byte),
    creation_date          date,
    created_by             number,
    last_update_date       date,
    last_updated_by        number
);

alter table samqa.broker_salesrep_assignment
    add constraint broker_salesrep_pk primary key ( brk_salesrep_assign_id )
        using index enable;

