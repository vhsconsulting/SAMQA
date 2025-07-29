create or replace procedure samqa.process_bps_deposits (
    p_file_name in varchar2
) is
    l_list_bill number;
    l_sqlerrm   varchar2(3200);
begin
    begin
        execute immediate 'ALTER TABLE settlement_external LOCATION (DEBIT_DIR:'''
                          || p_file_name
                          || ''')';
    exception
        when others then
            raise;
            dbms_output.put_line('Error message ' || sqlerrm);
    end;

    for x in (
        select
            sum(transaction_amount)        amount,
            to_date(substr(transaction_date, 1, 6),
                    'YYYYMM')              transaction_date,
            substr(transaction_date, 1, 8) check_number,
            c.entrp_id,
            nvl(a.plan_type, 'HRP')        plan_type
        from
            settlement_external a,
            account             b,
            person              c
        where
                a.employee_id = b.acc_num
            and b.pers_id = c.pers_id
            and transaction_code = '22'
            and transaction_date like '%00000000%'
            and transaction_process_code = 1
        group by
            to_date(substr(transaction_date, 1, 6),
                    'YYYYMM'),
            substr(transaction_date, 1, 8),
            c.entrp_id,
            nvl(a.plan_type, 'HRP')
    ) loop
        select
            employer_deposit_seq.nextval
        into l_list_bill
        from
            dual;

        dbms_output.put_line('list bill ' || l_list_bill);
        insert into employer_deposits (
            employer_deposit_id,
            entrp_id,
            list_bill,
            check_number,
            check_amount,
            check_date,
            posted_balance,
            remaining_balance,
            fee_bucket_balance,
            created_by,
            creation_date,
            last_updated_by,
            last_update_date,
            note,
            reason_code,
            plan_type
        ) values ( l_list_bill,
                   x.entrp_id,
                   l_list_bill,
                   x.check_number,
                   x.amount,
                   x.transaction_date,
                   x.amount,
                   0,
                   0,
                   0,
                   sysdate,
                   0,
                   sysdate,
                   'Deposit Migration from Metavante ' || sysdate,
                   11,
                   x.plan_type );

        insert into income (
            change_num,
            acc_id,
            fee_date,
            fee_code,
            amount,
            pay_code,
            cc_number,
            note,
            contributor,
            contributor_amount,
            list_bill,
            debit_card_posted,
            plan_type
        )
            select
                change_seq.nextval,
                acc_id,
                to_date(substr(transaction_date, 1, 6),
                        'YYYYMM'),
                11,
                transaction_amount,
                4,
                x.check_number,
                'Deposit Migration from Metavante ' || sysdate,
                x.entrp_id,
                x.amount,
                l_list_bill,
                'Y',
                a.plan_type
            from
                settlement_external a,
                person              b,
                account             c
            where
                    a.employee_id = c.acc_num
                and b.pers_id = c.pers_id
                and b.entrp_id = x.entrp_id
                and a.transaction_process_code = 1
                and not exists (
                    select
                        *
                    from
                        income
                    where
                            cc_number = x.check_number
                        and c.acc_id = income.acc_id
                        and b.entrp_id = income.contributor
                )
                and substr(transaction_date, 1, 8) = x.check_number
                and transaction_code = '22';

    end loop;

end;
/


-- sqlcl_snapshot {"hash":"ece74a2e3c3a724277334ac15ab6317d5b0ba040","type":"PROCEDURE","name":"PROCESS_BPS_DEPOSITS","schemaName":"SAMQA","sxml":""}