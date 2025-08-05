-- liquibase formatted sql
-- changeset SAMQA:1754374145342 stripComments:false logicalFilePath:BASE_RELEASE\samqa\procedures\refund_claim_invoice.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/procedures/refund_claim_invoice.sql:null:ba6ea917ecc7adc09df55ae4b9c19868b3fa1938:create

create or replace procedure samqa.refund_claim_invoice (
    p_invoice_id in number
) is
    l_claim_pay_id  number;
    l_return_status varchar2(255);
    l_error_message varchar2(2000);
begin
    for x in (
        select
            invoice_id,
            entrp_id,
            plan_type,
            acc_id,
            invoice_amount,
            sum(payment_amount) payment_amount,
            sum(paid_amount)    paid_amount
                --  ,  substr(WM_CONCAT(claim_id),1,3000) claim_ids  commented by RPRABU 17/10/2017
            ,
            substr(
                listagg(claim_id, ',') within group(
                order by
                    claim_id
                ),
                1,
                3000)        claim_ids -- added by rprabu on 17/10/2017
        from
            (
                select
                    b.invoice_id,
                    b.invoice_amount - b.void_amount invoice_amount,
                    case
                        when a.posting_status = 'PARTIALLY_POSTED' then
                            nvl(a.payment_amount, 0) - nvl(a.paid_amount, 0)
                        when a.posting_status = 'NOT_POSTED'       then
                            nvl(a.payment_amount, 0)
                        else
                            0
                    end                              payment_amount,
                    nvl(a.paid_amount, 0)            paid_amount,
                    b.entity_id                      entrp_id,
                    b.plan_type,
                    b.acc_id,
                    a.claim_id
                from
                    claim_invoice_posting a,
                    ar_invoice            b
                where
                        b.invoice_id = p_invoice_id
                    and a.invoice_id = b.invoice_id
                    and b.status = 'POSTED'
                    and a.posting_status in ( 'PARTIALLY_POSTED', 'NOT_POSTED' )
            ) b
        group by
            b.invoice_id,
            b.invoice_amount,
            b.entrp_id,
            b.plan_type,
            b.acc_id
        having sum(nvl(b.paid_amount, 0)) < b.invoice_amount
               and sum(nvl(b.paid_amount, 0)) <> b.invoice_amount
        order by
            b.invoice_id
    ) loop
        pc_log.log_error('refund_claim_invoice', 'Refund amount '
                                                 || x.payment_amount
                                                 || ' for '
                                                 || x.invoice_id);

        insert into employer_payments (
            employer_payment_id,
            entrp_id,
            check_amount,
            check_date,
            creation_date,
            created_by,
            last_update_date,
            last_updated_by,
            note,
            reason_code,
            transaction_date,
            plan_type,
            transaction_source,
            invoice_id
        ) values ( employer_payments_seq.nextval,
                   x.entrp_id,
                   x.payment_amount,
                   sysdate,
                   sysdate,
                   0,
                   sysdate,
                   0,
                   'Refund for Invoice ' || x.invoice_id,
                   25,
                   sysdate,
                   x.plan_type,
                   'RECEIPT',
                   x.invoice_id ) returning employer_payment_id into l_claim_pay_id;

        pc_claim.process_emp_refund(
            p_entrp_id            => x.entrp_id,
            p_pay_code            => 1,
            p_refund_amount       => x.payment_amount,
            p_emp_payment_id      => l_claim_pay_id,
            p_substantiate_reason => null     -- Added by Swamy for Ticket#5692(Impact Changes)
            ,
            x_return_status       => l_return_status,
            x_error_message       => l_error_message
        );

        if l_return_status <> 'S' then
            raise_application_error('-20001', l_error_message);
        end if;
        update claim_invoice_posting
        set
            employer_payment_id = l_claim_pay_id,
            posting_status = 'REFUNDED'
        where
                invoice_id = x.invoice_id
            and posting_status in ( 'NOT_POSTED', 'PARTIALLY_POSTED' );

        update ar_invoice
        set
            refund_amount = nvl(refund_amount, 0) + nvl(x.payment_amount, 0),
            last_update_date = sysdate
        where
            invoice_id = x.invoice_id;

      -- Do the notification
        pc_notifications.claim_invoice_refund_notify(
            p_invoice_id => x.invoice_id,
            p_claim_ids  => x.claim_ids,
            p_acc_id     => x.acc_id,
            p_entrp_id   => x.entrp_id
        );

        pc_notifications.email_partially_paid_claim_inv(x.invoice_id);
    end loop;
end refund_claim_invoice;
/

