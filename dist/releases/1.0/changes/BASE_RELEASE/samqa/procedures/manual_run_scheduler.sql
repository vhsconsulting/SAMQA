-- liquibase formatted sql
-- changeset SAMQA:1754374144302 stripComments:false logicalFilePath:BASE_RELEASE\samqa\procedures\manual_run_scheduler.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/procedures/manual_run_scheduler.sql:null:3b0a606dd73956a397c9e4bcb16a7f3804578adf:create

create or replace procedure samqa.manual_run_scheduler (
    p_payroll_date in date
) as
begin
    for x in (
        select
            scheduler_id,
            s.acc_id                                                    m_acc_id,
            payment_method,
            payment_type,
            reason_code,
            payment_start_date,
            payment_end_date,
            recurring_flag,
            amount,
            fee_amount,
            bank_acct_id,
            contributor,
            plan_type,
            decode(orig_system_source, 'CLAIMN', orig_system_ref, null) claim_id
        from
            scheduler_master   s,
            scheduler_calendar sc
        where
                trunc(payment_end_date) >= p_payroll_date
            and trunc(payment_start_date) <= p_payroll_date
            and payment_method = 'PAYROLL'
            and sc.schedule_id = s.scheduler_id
            and trunc(sc.period_date) = p_payroll_date
            and nvl(s.status, 'A') = 'A'
    ) loop
        pc_schedule.process_schedule(x.scheduler_id, null, null);
    end loop;
end;
/

