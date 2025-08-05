-- liquibase formatted sql
-- changeset SAMQA:1754374161870 stripComments:false logicalFilePath:BASE_RELEASE\samqa\tables\pay_details.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/tables/pay_details.sql:null:93a6f9c5d766d3417c03595c27673be919bcee69:create

create table samqa.pay_details (
    acc_id             number,
    ben_plan_id        number,
    first_payroll_date varchar2(200 byte),
    pay_contrb         number,
    no_of_periods      number,
    pay_cycle          varchar2(255 byte),
    effective_date     date,
    creation_date      date,
    created_by         number,
    last_update_date   date,
    last_updated_by    number,
    pay_detail_id      number,
    ben_plan_id_main   number,
    ee_pay_contrib     number,
    source             varchar2(30 byte),
    pay_cycle_id       number
);

