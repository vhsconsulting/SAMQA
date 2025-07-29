create or replace procedure samqa.migrate_claims as
    l_claim_id     number;
    l_batch_number number;
begin
    for x in (
        select
            a.claim_id,
            decode(a.claim_type, 'SUBSCRIBER_ONLINE_ACH', 19, 'PROVIDER_ONLINE', 11,
                   'SUBSCRIBER_ONLINE', 12)    pay_reason,
            nvl(a.cancelled_flag, 'N')         cancelled,
            nvl(a.claim_error_flag, 'N')       claim_error,
            nvl(a.insufficient_fund_flag, 'N') insufficient,
            a.vendor_id,
            a.bank_acct_id,
            b.claim_amount
        from
            payment_register a,
            claimn           b,
            payment          c,
            account          d
        where
                a.claim_id = b.claim_id
            and c.claimn_id = b.claim_id
            and d.acc_id = c.acc_id
            and d.account_type = 'HSA'
    ) loop
        if x.cancelled = 'Y' then
            update claimn
            set
                claim_status = 'CANCELLED',
                bank_acct_id = x.bank_acct_id,
                vendor_id = x.vendor_id,
                pay_reason = x.pay_reason
            where
                claim_id = x.claim_id;

        end if;

        if x.claim_error = 'Y' then
            update claimn
            set
                claim_status = 'ERROR',
                bank_acct_id = x.bank_acct_id,
                vendor_id = x.vendor_id,
                pay_reason = x.pay_reason
            where
                claim_id = x.claim_id;

        end if;

        if x.claim_error = 'Y' then
            update claimn
            set
                claim_status = 'ERROR',
                bank_acct_id = x.bank_acct_id,
                vendor_id = x.vendor_id,
                pay_reason = x.pay_reason
            where
                claim_id = x.claim_id;

        end if;

    end loop;

    for x in (
        select
            b.claim_id,
            sum(c.amount) pay_amount,
            b.claim_amount
        from
            claimn  b,
            payment c,
            account d
        where
                c.claimn_id = b.claim_id
            and d.acc_id = c.acc_id
            and d.account_type = 'HSA'
            and c.reason_code in ( 11, 12, 13, 19 )
        group by
            b.claim_id,
            b.claim_amount
    ) loop
        if x.claim_amount = x.pay_amount then
            update claimn
            set
                claim_status = 'PAID'
            where
                    claim_id = x.claim_id
                and claim_status is null;

        else
            if
                x.claim_amount > x.pay_amount
                and x.pay_amount > 0
            then
                update claimn
                set
                    claim_status = 'PARTIALLY_PAID'
                where
                    claim_id = x.claim_id;

            end if;
        end if;

  /*    UPDATE PAYMENT
      SET    PAID_DATE = PAY_DATE
      WHERE  CLAIMN_ID = X.CLAIM_ID;*/
    end loop;

    l_batch_number := batch_num_seq.nextval;
    for x in (
        select
            a.transaction_id,
            b.pers_id,
            b.acc_num,
            b.acc_id,
            a.total_amount
        from
            ach_transfer_v a,
            account        b
        where
                a.acc_id = b.acc_id
            and account_type = 'HSA'
            and a.status in ( 1, 2 )
            and a.transaction_type = 'D'
    ) loop

       -- Commented out as part of the HSA claim redesign flow: HEX project
        l_claim_id := doc_seq.nextval;
        insert into payment_register (
            payment_register_id,
            batch_number,
            acc_num,
            acc_id,
            pers_id,
            provider_name,
            claim_code,
            claim_id,
            trans_date,
            gl_account,
            cash_account,
            claim_amount,
            claim_type,
            peachtree_interfaced,
            check_number,
            note
        )
            select
                payment_register_seq.nextval,
                l_batch_number,
                x.acc_num,
                x.acc_id,
                x.pers_id,
                'eDisbursement',
                upper(substr(b.last_name, 1, 4))
                || to_char(sysdate, 'YYYYMMDDHHMISS')
                || x.transaction_id,
                l_claim_id,
                sysdate,
                (
                    select
                        account_num
                    from
                        payment_acc_info
                    where
                            account_type = 'GL_ACCOUNT'
                        and status = 'A'
                ),
                nvl((
                    select
                        account_num
                    from
                        payment_acc_info
                    where
                        substr(account_type, 1, 3) like substr(x.acc_num, 1, 3)
                                                        || '%'
                        and status = 'A'
                ),
                    (
                    select
                        account_num
                    from
                        payment_acc_info
                    where
                            substr(account_type, 1, 3) = 'SHA'
                        and status = 'A'
                )),
                x.total_amount,
                'ONLINE',
                'Y',
                x.transaction_id,
                'Online Disbursement'
            from
                person b
            where
                    b.pers_id = x.pers_id
                and not exists (
                    select
                        *
                    from
                        payment_register
                    where
                        claim_code like upper(substr(b.last_name, 1, 4))
                                        || '%'
                                        || x.transaction_id
                );

        insert into claimn (
            claim_id,
            pers_id,
            pers_patient,
            claim_code,
            prov_name,
            claim_date_start,
            claim_date_end,
            service_status,
            claim_amount,
            claim_paid,
            claim_pending,
            note
        )
            select
                claim_id,
                pers_id,
                pers_id,
                claim_code,
                provider_name,
                sysdate,
                trans_date,
                3,
                claim_amount,
                claim_amount,
                0,
                'Disbursement Created for ' || to_char(sysdate, 'YYYYMMDD')
            from
                payment_register a
            where
                    a.batch_number = l_batch_number
                and a.acc_id = x.acc_id
                and a.claim_id = l_claim_id
                and a.check_number = x.transaction_id
                and not exists (
                    select
                        *
                    from
                        claimn
                    where
                        claim_id = a.claim_id
                );

    end loop;

end;
/


-- sqlcl_snapshot {"hash":"346627b176e0be6110b850583ed2a590ee229175","type":"PROCEDURE","name":"MIGRATE_CLAIMS","schemaName":"SAMQA","sxml":""}