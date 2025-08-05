-- liquibase formatted sql
-- changeset SAMQA:1754374161883 stripComments:false logicalFilePath:BASE_RELEASE\samqa\tables\pay_details_t.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/tables/pay_details_t.sql:null:98d90019bad4140b1f023f4021dba3ef945f3ba8:create

create table samqa.pay_details_t (
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
    ben_plan_id_main   number
);

