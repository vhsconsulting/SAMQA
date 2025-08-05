create or replace procedure samqa.create_employer_payment as
begin
    insert into employer_payments (
        employer_payment_id,
        entrp_id,
        check_amount,
        check_number,
        check_date,
        creation_date,
        created_by,
        last_update_date,
        last_updated_by,
        note,
        bank_acct_id,
        payment_register_id,
        list_bill,
        reason_code,
        transaction_date,
        plan_type,
        pay_code,
        transaction_source,
        plan_start_date,
        plan_end_date,
        memo,
        invoice_id
    )
        select
            employer_payments_seq.nextval,
            entrp_id,
            pay_amount,
            check_num,
            paid_date,
            sysdate,
            0,
            sysdate,
            0,
            pc_lookups.get_reason_name(reason_code),
            null,
            null,
            null,
            reason_code,
            paid_date,
            service_type,
            null,
            'CLAIM_PAYMENT',
            plan_start_date,
            plan_end_date,
            null,
            null
        from
            (
                select
                    p.entrp_id,
                    sum(nvl(c.amount, 0)) pay_amount,
                    'CLAIM_PAYMENT_'
                    || to_char(
                        trunc(c.paid_date),
                        'MMDDYYYY'
                    )                     check_num,
                    reason_code,
                    trunc(c.paid_date)    paid_date,
                    p.service_type,
                    p.plan_start_date,
                    p.plan_end_date
                from
                    account acc,
                    claimn  p,
                    payment c
                where
                    acc.account_type in ( 'HRA', 'FSA' )
                    and acc.pers_id = p.pers_id
                    and p.claim_id = c.claimn_id
 -- AND C.REASON_CODE       NOT IN (1,2)
                    and p.service_type = c.plan_type
                    and c.acc_id = acc.acc_id
 -- AND P.ENTRP_ID = 7457
                group by
                    p.entrp_id,
                    'CLAIM_PAYMENT_'
                    || to_char(
                        trunc(c.paid_date),
                        'MMDDYYYY'
                    ),
                    reason_code,
                    trunc(c.paid_date),
                    p.service_type,
                    p.plan_start_date,
                    p.plan_end_date
                order by
                    trunc(c.paid_date) desc
            )
        where
            pay_amount <> 0;

end;
/


-- sqlcl_snapshot {"hash":"8cfd1ee45708c6e19efacbf1e15c5583cd84210b","type":"PROCEDURE","name":"CREATE_EMPLOYER_PAYMENT","schemaName":"SAMQA","sxml":""}