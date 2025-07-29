create or replace procedure samqa.release_invoiced_claims (
    p_invoice_id in number
) as
    l_return_status varchar2(255);
    l_error_message varchar2(255);
begin
    for xx in (
        select
            *
        from
            claim_invoice_posting a
        where
                a.invoice_id = p_invoice_id
            and invoice_id <> 47799
    ) loop
        pc_claim.process_finance_claim(
            p_claim_id      => xx.claim_id,
            p_claim_status  => 'READY_TO_PAY',
            p_user_id       => 0,
            x_return_status => l_return_status,
            x_error_message => l_error_message
        );

        for x in (
            select
                a.claim_id,
                ck.check_amount balance,
                b.acc_num,
                d.claim_type,
                a.pers_id,
                b.acc_id,
                ck.check_number change_num,
                a.pay_reason    reason_code,
                a.claim_status  claim_status_code
            from
                claimn           a,
                account          b,
                payment_register d,
                checks           ck
            where
                    a.claim_id = xx.claim_id
                and a.pers_id = b.pers_id
                and d.claim_id = a.claim_id
                and ck.entity_type = 'CLAIMN'
                and ck.status = 'READY'
                and ck.entity_id = a.claim_id
                and d.acc_num = b.acc_num
                and a.claim_amount > 0
            union
            select
                a.claim_id,
                n.total_amount balance,
                b.acc_num,
                d.claim_type,
                a.pers_id,
                b.acc_id,
                to_char(n.transaction_id),
                d.pay_reason,
                a.claim_status claim_status_code
            from
                claimn           a,
                account          b,
                payment_register d,
                ach_transfer     n
            where
                    a.claim_id = xx.claim_id -- p_claim_id_tbl(i)
                and a.pers_id = b.pers_id
                and d.claim_id = a.claim_id
                and a.claim_id = n.claim_id
                and b.acc_id = n.acc_id
                and d.acc_num = b.acc_num
                and a.claim_amount > 0
                and trunc(n.transaction_date) >= trunc(sysdate)
        ) loop
            update claim_invoice_posting
            set
                change_num =
                    case
                        when x.reason_code in ( 11, 12 ) then
                            x.change_num
                        else
                            null
                    end,
                transaction_id =
                    case
                        when x.reason_code = 19 then
                            x.change_num
                        else
                            null
                    end,
                paid_amount = x.balance,
                payment_status = x.claim_status_code,
                posting_status =
                    case
                        when payment_amount = x.balance then
                            'POSTED'
                        when payment_amount > x.balance then
                            'PARTIALLY_POSTED' -- pay what we invoice change
                    end,
                pay_date = sysdate
            where
                    claim_id = x.claim_id
                and posting_status = 'NOT_POSTED'
                and change_num is null
                and transaction_id is null
                and payment_status is null;

        end loop;

    end loop;

   
   /*** Vanitha : 23-oct-2016: Pay what we invoice enhancements ****/
    for xxx in (
        select
            count(*) cnt
        from
            ach_transfer at
        where
            at.invoice_id = p_invoice_id
    ) loop
        if xxx.cnt = 0 then
            refund_claim_invoice(p_invoice_id);
        end if;
    end loop;

    for xx in (
        select
            entity_id
        from
            ar_invoice
        where
            invoice_id = p_invoice_id
    ) loop
        pc_employer_fin.create_employer_payment(xx.entity_id, sysdate);
    end loop;

    pc_claim_automation.write_invoiced_claim_file(p_invoice_id);
end release_invoiced_claims;
/


-- sqlcl_snapshot {"hash":"1c4a0db9d97ea3bfdfb203163cc812a42f37d8ff","type":"PROCEDURE","name":"RELEASE_INVOICED_CLAIMS","schemaName":"SAMQA","sxml":""}