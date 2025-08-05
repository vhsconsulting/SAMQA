-- liquibase formatted sql
-- changeset SAMQA:1754374161856 stripComments:false logicalFilePath:BASE_RELEASE\samqa\tables\pay_cycle_stage.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/tables/pay_cycle_stage.sql:null:b88cc9fd42d8ffe058f29a05ff49cac334c86cd1:create

create table samqa.pay_cycle_stage (
    enrollment_detail_id number,
    plan_type            varchar2(100 byte),
    frequency            varchar2(100 byte),
    pay_periods          number,
    start_date           date,
    ben_plan_id          number,
    status               varchar2(2 byte),
    batch_number         number,
    creation_date        date,
    created_by           number,
    pay_cycle_id         number
);

