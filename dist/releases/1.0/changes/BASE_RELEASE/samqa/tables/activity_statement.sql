-- liquibase formatted sql
-- changeset SAMQA:1754374151293 stripComments:false logicalFilePath:BASE_RELEASE\samqa\tables\activity_statement.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/tables/activity_statement.sql:null:7653b00e727543f0e3f00a8c5708c3592406e1ac:create

create table samqa.activity_statement (
    statement_id        number,
    acc_num             varchar2(30 byte),
    acc_id              number,
    pers_id             number,
    start_date          date,
    begin_date          date,
    end_date            date,
    name                varchar2(3200 byte),
    address             varchar2(3200 byte),
    city                varchar2(255 byte),
    state               varchar2(255 byte),
    zip                 varchar2(255 byte),
    coverage_level      varchar2(255 byte),
    contribution_limit  number,
    beginning_balance   number,
    ending_balance      number,
    disbursable_balance number,
    beg_fee_balance     number,
    end_fee_balance     number,
    interest            number,
    outside_inv_bal     number,
    previous_yr_contrib number,
    current_yr_contrib  number,
    total_contribution  number,
    qual_disb_amount    number,
    nqual_disb_amount   number,
    total_disbursement  number,
    txn_fee_paid        number,
    admin_fee_paid      number,
    creation_date       date,
    plan_sign           varchar2(30 byte),
    batch_number        number,
    total_er_amount     number,
    total_ee_amount     number,
    statement_method    varchar2(30 byte)
);

