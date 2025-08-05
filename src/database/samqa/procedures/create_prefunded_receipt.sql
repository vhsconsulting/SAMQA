create or replace procedure samqa.create_prefunded_receipt (
    p_batch_number in number,
    p_user_id      in number,
    p_acc_num      in varchar2 default null
) is
    l_list_bill number;
begin
    for x in (
        select
            a.ben_plan_id,
            a.entrp_id,
            a.plan_type,
            a.plan_start_date,
            c.acc_num,
            sum(nvl(b.annual_election, 0)) check_amount
        from
            ben_plan_enrollment_setup a,
            ben_plan_enrollment_setup b,
            account                   c
        where
                a.ben_plan_id = b.ben_plan_id_main
            and a.acc_id = c.acc_id
            and c.acc_num = nvl(p_acc_num, c.acc_num)
            and b.plan_type = 'HRA'
               --  AND    B.PLAN_TYPE   IN ('FSA','LPF')
            and c.account_type in ( 'HRA', 'FSA' )
            and a.entrp_id is not null
            and a.plan_type is not null
            and exists (
                select
                    *
                from
                    income d
                where
                        trunc(a.plan_start_date) >= trunc(d.fee_date)
                    and b.acc_id = d.acc_id
                    and d.fee_code = 12
            )
            and not exists (
                select
                    *
                from
                    income d
                where
                        trunc(a.plan_start_date) >= trunc(d.fee_date)
                    and b.acc_id = d.acc_id
                    and d.fee_code = 11
            )
             --   AND   TRUNC(A.PLAN_END_DATE) >= TRUNC(SYSDATE)
        group by
            a.ben_plan_id,
            a.entrp_id,
            a.plan_type,
            a.plan_start_date,
            c.acc_num
        having
            sum(nvl(b.annual_election, 0)) > 0
    ) loop
        select
            employer_deposit_seq.nextval
        into l_list_bill
        from
            dual;
       /*   pc_fin.create_employer_deposit
           (p_list_bill          => L_LIST_BILL
          , p_entrp_id           => x.entrp_id
          , p_check_amount       => x.check_amount
          , p_check_date         => x.PLAN_START_DATE
          , p_posted_balance     => x.check_amount
          , p_fee_bucket_balance => 0
          , p_remaining_balance  => 0
          , p_user_id            => p_user_id
          , p_plan_type          => X.PLAN_TYPE
          , p_note               => 'Posting Prefunded Payroll Contribution'
	  , p_reason_code        => 11);*/
        insert into employer_deposits a (
            employer_deposit_id,
            entrp_id,
            list_bill,
            check_number,
            check_amount,
            check_date,
            posted_balance,
            fee_bucket_balance,
            remaining_balance,
            created_by,
            creation_date,
            last_updated_by,
            last_update_date,
            note,
            plan_type,
            reason_code
        ) values ( l_list_bill -- EMPLOYER_DEPOSIT_ID
        ,
                   x.entrp_id -- ENTRP_ID
                   ,
                   l_list_bill-- LIST_BILL
                   ,
                   l_list_bill
                   || to_char(x.plan_start_date, 'MMDDYYYY') -- CHECK_NUMBER
                   ,
                   x.check_amount -- CHECK_AMOUNT
                   ,
                   x.plan_start_date   -- CHECK_DATE
                   ,
                   x.check_amount  -- POSTED_BALANCE
                   ,
                   0   -- FEE_BUCKET_BALANCE
                   ,
                   0 -- REMAINING_BALANCE
                   ,
                   0 -- CREATED_BY
                   ,
                   sysdate   -- CREATION_DATE
                   ,
                   0 -- LAST_UPDATED_BY
                   ,
                   sysdate   -- LAST_UPDATE_DATE
                   ,
                   'Posting Prefunded Deposit',
                   x.plan_type,
                   11 ); -- NOTE


        for xx in (
            select
                *
            from
                ben_plan_enrollment_setup
            where
                ben_plan_id_main = x.ben_plan_id
        ) loop
            begin
                pc_fin.create_receipt(
                    p_acc_id            => xx.acc_id,
                    p_fee_date          => x.plan_start_date,
                    p_entrp_id          => x.entrp_id,
                    p_er_amount         => nvl(xx.annual_election, 0),
                    p_pay_code          => 6,
                    p_plan_type         => x.plan_type,
                    p_debit_card_posted => 'Y',
                    p_list_bill         => l_list_bill,
                    p_fee_reason        => 11,
                    p_note              => 'Posting Prefunded Payroll Contribution',
                    p_check_amount      => x.check_amount,
                    p_user_id           => p_user_id
                );

            exception
                when others then
                    dbms_output.put_line('ACC ID ' || xx.acc_id);
            end;
        end loop;

    end loop;
end create_prefunded_receipt;
/


-- sqlcl_snapshot {"hash":"76b819b29c36068490ba860f75e216dd99a81fb9","type":"PROCEDURE","name":"CREATE_PREFUNDED_RECEIPT","schemaName":"SAMQA","sxml":""}