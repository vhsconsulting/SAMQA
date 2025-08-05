-- liquibase formatted sql
-- changeset SAMQA:1754374162043 stripComments:false logicalFilePath:BASE_RELEASE\samqa\tables\payroll_contribution.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/tables/payroll_contribution.sql:null:fb4760f7ad254efe6ace2270c9120d553cf01645:create

create table samqa.payroll_contribution (
    payroll_contribution_id number,
    acc_id                  number,
    payroll_date            date,
    payroll_amount          number,
    plan_type               varchar2(30 byte),
    entrp_id                number,
    scheduler_id            number,
    scheduler_detail_id     number,
    processed_flag          varchar2(1 byte),
    invoice_id              number,
    creation_date           date default sysdate,
    created_by              number,
    last_update_date        date default sysdate,
    last_updated_by         number
);

alter table samqa.payroll_contribution add primary key ( payroll_contribution_id )
    using index enable;

