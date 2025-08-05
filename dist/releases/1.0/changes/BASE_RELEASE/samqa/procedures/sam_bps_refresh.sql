-- liquibase formatted sql
-- changeset SAMQA:1754374146080 stripComments:false logicalFilePath:BASE_RELEASE\samqa\procedures\sam_bps_refresh.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/procedures/sam_bps_refresh.sql:null:4d53e5b5e8c9d4dea0adb44cb12cec21ca6a3e7e:create

create or replace procedure samqa.sam_bps_refresh as
begin
    execute immediate 'TRUNCATE TABLE bps_sam_balances';
    insert into bps_sam_balances (
        acc_num,
        acc_id,
        plan_type,
        plan_start_date,
        plan_end_date,
        disbursable_balance,
        bps_disb_ptd,
        bps_cont_ptd,
        entrp_id
    )
        select
            b.acc_num,
            b.acc_id,
            bp.plan_type,
            bp.plan_start_date,
            bp.plan_end_date,
            a.disbursable_balance,
            a.deductible_ptd,
            a.employee_contribution_ytd + a.employer_contribution_ytd,
            p.entrp_id
        from
            card_balance_external     a,
            account                   b,
            ben_plan_enrollment_setup bp,
            person                    p
        where
                a.plan_type <> 'HSA'
            and a.card_number is not null
            and to_date(a.plan_start_date, 'YYYYMMDD') = bp.plan_start_date
            and to_date(a.plan_end_date, 'YYYYMMDD') = bp.plan_end_date
            and a.plan_type = bp.plan_type
            and a.employee_id = b.acc_num
            and b.acc_id = bp.acc_id
            and p.pers_id = b.pers_id
            and bp.plan_end_date + nvl(runout_period_days, 0) + nvl(grace_period, 0) > sysdate;

    update bps_sam_balances
    set
        sam_bal = pc_account.acc_balance(acc_id, plan_start_date, plan_end_date, account_type, plan_type);

    update bps_sam_balances
    set
        bal_dff = disbursable_balance - sam_bal;

end sam_bps_refresh;
/

