create or replace force editionable view samqa.fsahra_contribution_summary_v (
    acc_id,
    acc_num,
    entrp_id,
    er_acc_id,
    er_acc_num,
    plan_type,
    ben_plan_id,
    annual_election,
    scheduled_contribution,
    total_scheduled_amount,
    adjustment,
    contributed_amount,
    no_of_cont,
    er_ben_plan_id,
    plan_start_date,
    plan_end_date
) as
    select
        acc_id,
        acc_num,
        entrp_id,
        er_acc_id,
        er_acc_num,
        plan_type,
        ben_plan_id,
        annual_election,
        sum(scheduled_contribution)                                          scheduled_contribution,
        sum(scheduled_contribution * nvl(no_of_cont, 1))                     total_scheduled_amount,
        annual_election - sum((scheduled_contribution * nvl(no_of_cont, 1))) adjustment,
        sum(contributed_amount),
        no_of_cont,
        er_ben_plan_id,
        plan_start_date,
        plan_end_date
    from
        (
            select
                m.acc_id,
                acc.acc_num,
                er_acc.entrp_id,
                er_acc.acc_id                                                                                       er_acc_id,
                er_acc.acc_num                                                                                      er_acc_num,
                d.annual_election,
                mm.plan_type,
                d.ben_plan_id,
                sum(nvl(m.er_amount, 0) + nvl(m.ee_amount, 0))                                                      scheduled_contribution
                ,
                pc_schedule.get_contributed_amt(m.acc_id, mm.plan_type, mm.payment_start_date, mm.payment_end_date) contributed_amount
                ,
                sum(pc_schedule.get_schedule_count(mm.acc_id,
                                                   mm.scheduler_id,
                                                   mm.recurring_frequency,
                                                   greatest(mm.payment_start_date, d.effective_date),
                                                   (case
                                                           when months_between(mm.payment_end_date,
                                                                               greatest(mm.payment_start_date, d.effective_date)) > 12
                                                                               then
                                                               add_months(
                                                                   trunc(mm.payment_end_date, 'YYYY'),
                                                                   12
                                                               )
                                                           else mm.payment_end_date
                                                       end)))                                                                                              no_of_cont
                                                       ,
                d.ben_plan_id_main                                                                                  er_ben_plan_id,
                d.plan_start_date,
                d.plan_end_date
            from
                scheduler_details         m,
                scheduler_master          mm,
                ben_plan_enrollment_setup d,
                account                   acc,
                account                   er_acc
            where
                    m.scheduler_id = mm.scheduler_id
                and m.acc_id = d.acc_id
                and m.acc_id = acc.acc_id
                and d.acc_id = acc.acc_id
                and d.plan_type = mm.plan_type
                and er_acc.acc_id = mm.acc_id
                and d.plan_start_date <= mm.payment_start_date
                and d.plan_end_date >= mm.payment_end_date
                and mm.recurring_flag = 'Y'
                and m.status = 'A'
                and d.status <> 'R'
            group by
                m.acc_id,
                acc.acc_num,
                er_acc.entrp_id,
                er_acc.acc_id,
                er_acc.acc_num,
                d.annual_election,
                mm.plan_type,
                d.ben_plan_id,
                mm.payment_start_date,
                mm.payment_end_date,
                d.ben_plan_id_main,
                d.plan_start_date,
                d.plan_end_date
            order by
                acc_num
        )
    group by
        acc_id,
        acc_num,
        entrp_id,
        er_acc_id,
        er_acc_num,
        plan_type,
        ben_plan_id,
        annual_election,
        no_of_cont,
        er_ben_plan_id,
        plan_start_date,
        plan_end_date;


-- sqlcl_snapshot {"hash":"8685c50ca0d5680ce3c1743a21ccc61db4f33b09","type":"VIEW","name":"FSAHRA_CONTRIBUTION_SUMMARY_V","schemaName":"SAMQA","sxml":""}