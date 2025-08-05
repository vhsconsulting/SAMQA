create or replace procedure samqa.run_hsa_manual_scheuler (
    p_schedule_id in number,
    p_user_id     in number default 0
) is

    date_list        pc_schedule.schedule_date_table;
    l_transaction_id number;
    return_status    varchar2(1);
    error_message    varchar2(300);
    app_exception exception;
    l_acc_id         number;
    l_amount         number := 0;
    l_fee_amount     number := 0;
    l_trans_type     varchar2(1);
    l_xfer_detail_id number;
    l_list_bill      number;
    l_trans_date     date;
    l_count          number := 0;
    cursor cur_sched is
    select
        scheduler_id,
        m_acc_id,
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
        recurring_frequency,
        claim_id
    from
        er_bank_draft_manual_v s
    where
        scheduler_id = p_schedule_id;

    cursor cur_details (
        p_scheduler_id  number,
        p_schedule_date date
    ) is
    select
        sd.acc_id             d_acc_id,
        nvl(er_amount, 0)     er_amount,
        nvl(ee_amount, 0)     ee_amount,
        nvl(er_fee_amount, 0) er_fee_amount,
        nvl(ee_fee_amount, 0) ee_fee_amount,
        sd.scheduler_detail_id
    from
        scheduler_details sd,
        scheduler_master  sm,
        account           acc
    where
            sd.scheduler_id = p_scheduler_id
        and sm.payment_method = 'ACH'
        and sd.scheduler_id = sm.scheduler_id
        and acc.acc_id = sd.acc_id
        and acc.account_status <> 4
        and nvl(er_amount, 0) + nvl(ee_amount, 0) + nvl(er_fee_amount, 0) + nvl(ee_fee_amount, 0) > 0
        and sd.status = 'A';

begin
  --dbms_output.put_line('process started');
    for x in cur_sched loop
        date_list.delete;
        if
            x.recurring_flag = 'Y'
            and p_schedule_id is not null
        then
            for xx in (
                select
                    period_date
                from
                    scheduler_calendar
                where
                        schedule_id = x.scheduler_id
                    and trunc(period_date) <= trunc(sysdate)
            ) loop
                date_list(date_list.count) := xx.period_date;
                dbms_output.put_line('p_scheduler is not null x.scheduler_id: '
                                     || x.scheduler_id
                                     || 'x.period_date: '
                                     || xx.period_date);

            end loop;

        elsif
            x.recurring_flag = 'Y'
            and p_schedule_id is null
        then
            for xx in (
                select
                    period_date
                from
                    scheduler_calendar
                where
                        schedule_id = x.scheduler_id
                    and trunc(period_date) = trunc(sysdate)
            ) loop
                date_list(date_list.count) := xx.period_date;
        -- dbms_output.put_line('p_scheduler is null x.scheduler_id: ' || x.scheduler_id || 'x.recurring_flag: ' || x.recurring_flag );

            end loop;
        else
            date_list(1) := x.payment_start_date;
        ---dbms_output.put_line('recurring flag N x.scheduler_id: ' || x.scheduler_id || 'x.recurring_flag: ' || x.recurring_flag );
        end if;

        if date_list.count > 0 then
            for ind in date_list.first..date_list.last loop
                pc_log.log_error('pc_scheduler.process_ach_schedule',
                                 'x.scheduler_id: '
                                 || x.scheduler_id
                                 || 'date_list(ind):'
                                 || date_list(ind));
       -- dbms_output.put_line('x.scheduler_id: ' || x.scheduler_id ||'date_list(ind):' || date_list(ind) );
                l_transaction_id := null;
                if
                    x.payment_method = 'ACH'
                    and x.payment_type = 'C'
                    and x.contributor is not null
                then
                    l_transaction_id := null;
                    if pc_schedule.check_ach_scheduled('BANK_DRAFT',
                                                       null,
                                                       x.m_acc_id,
                                                       date_list(ind),
                                                       nvl(x.amount, 0) + nvl(x.fee_amount, 0),
                                                       x.payment_type,
                                                       x.scheduler_id) = 'N' then
                        if x.plan_type is null then

               /* pc_ach_transfer.ins_ach_transfer(x.m_acc_id, x.bank_acct_id,x.payment_type,
                               x.amount, x.fee_amount,date_list(ind)
                               , x.reason_code,
                               2,p_user_id, 3,l_transaction_id,return_status, error_message);
              */

                            insert into ach_transfer (
                                transaction_id,
                                acc_id,
                                bank_acct_id,
                                transaction_type,
                                amount,
                                fee_amount,
                                total_amount,
                                transaction_date,
                                reason_code,
                                status,
                                pay_code,
                                last_updated_by,
                                created_by,
                                last_update_date,
                                creation_date,
                                ach_source
                            ) values ( ach_transfer_seq.nextval,
                                       x.m_acc_id,
                                       x.bank_acct_id,
                                       x.payment_type,
                                       x.amount,
                                       x.fee_amount,
                                       nvl(x.amount, 0) + nvl(x.fee_amount, 0),
                                       date_list(ind),
                                       x.reason_code,
                                       2,
                                       5,
                                       p_user_id,
                                       p_user_id,
                                       sysdate,
                                       sysdate,
                                       'ONLINE' ) returning transaction_id into l_transaction_id;

                        end if;

                    end if;

                    if return_status != 'S' then
                        raise app_exception;
                    end if;
                    if l_transaction_id is not null then
           -- dbms_output.put_line('l_transaction_id: ' || l_transaction_id);
                        pc_log.log_error('pc_scheduler.process_ach_schedule', 'l_transaction_id: ' || l_transaction_id);
                        for det in cur_details(x.scheduler_id,
                                               date_list(ind)) loop
              -- dbms_output.put_line(det.d_acc_id);
                            if nvl(det.ee_amount, 0) + nvl(det.er_amount, 0) + nvl(det.ee_fee_amount, 0) + nvl(det.er_fee_amount, 0) > 0
                            then
                                insert into ach_transfer_details (
                                    xfer_detail_id,
                                    transaction_id,
                                    group_acc_id,
                                    acc_id,
                                    ee_amount,
                                    er_amount,
                                    ee_fee_amount,
                                    er_fee_amount,
                                    last_updated_by,
                                    created_by,
                                    last_update_date,
                                    creation_date
                                ) values ( ach_transfer_details_seq.nextval,
                                           l_transaction_id,
                                           x.m_acc_id,
                                           det.d_acc_id,
                                           det.ee_amount,
                                           det.er_amount,
                                           det.ee_fee_amount,
                                           det.er_fee_amount,
                                           p_user_id,
                                           p_user_id,
                                           sysdate,
                                           sysdate );

                            end if;

                            if return_status != 'S' then
                                raise app_exception;
                            end if;
                        end loop;   -- det

                        if x.recurring_flag = 'N' then
                            update scheduler_master
                            set
                                status = 'P'
                            where
                                scheduler_id = x.scheduler_id;

                        end if;

                    end if;

                    for zz in (
                        select
                            sum(nvl(det.ee_amount, 0) + nvl(det.er_amount, 0))                                                         amount
                            ,
                            sum(nvl(det.ee_fee_amount, 0) + nvl(det.er_fee_amount, 0))                                                 fee_amount
                            ,
                            sum(nvl(det.ee_amount, 0) + nvl(det.er_amount, 0) + nvl(det.ee_fee_amount, 0) + nvl(det.er_fee_amount, 0)
                            ) total_amount
                        from
                            ach_transfer_details det
                        where
                            transaction_id = l_transaction_id
                        group by
                            transaction_id
                    ) loop
                        update ach_transfer
                        set
                            amount = zz.amount,
                            fee_amount = zz.fee_amount,
                            total_amount = zz.total_amount,
                            scheduler_id = x.scheduler_id
                        where
                            transaction_id = l_transaction_id;

                    end loop;

                end if; -- payment_method = 'ACH'
            end loop; --date list
        end if; -- date list
    end loop;  --scheduler

 -- commit;
exception
    when app_exception then
        rollback;
        raise_application_error(-20040, error_message);
    when others then
        rollback;
        raise_application_error(-20041, 'Scheduling process failed. ' || sqlerrm);
end;
/


-- sqlcl_snapshot {"hash":"2af8294c2dc73060a71658b159a4f624269cf6f7","type":"PROCEDURE","name":"RUN_HSA_MANUAL_SCHEULER","schemaName":"SAMQA","sxml":""}