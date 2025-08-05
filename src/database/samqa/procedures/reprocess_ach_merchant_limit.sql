create or replace procedure samqa.reprocess_ach_merchant_limit (
    p_date   in date,
    p_acc_id in number
) as
    l_trans_id number;
begin
    for x in (
        select
            a.transaction_id trans_id,
            d.entrp_id
        from
            ach_transfer a,
            account      d
        where
                a.bankserv_status = 'DECLINED'
            and a.error_message like 'DE%MERCHANT LIMIT'
            and trunc(a.transaction_date) = p_date
            and a.acc_id = nvl(p_acc_id, a.acc_id)
            and a.acc_id = d.acc_id
    ) loop
        l_trans_id := ach_transfer_seq.nextval;
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
            error_message,
            processed_date,
            last_updated_by,
            created_by,
            last_update_date,
            creation_date,
            bankserv_status,
            batch_number,
            claim_id,
            plan_type,
            pay_code,
            invoice_id,
            ach_source,
            scheduler_id
        )
            select
                l_trans_id,
                acc_id,
                bank_acct_id,
                transaction_type,
                amount,
                fee_amount,
                total_amount,
                transaction_date,
                reason_code,
                2,
                null,
                processed_date,
                last_updated_by,
                created_by,
                sysdate,
                sysdate,
                null,
                batch_number,
                claim_id,
                plan_type,
                pay_code,
                invoice_id,
                ach_source,
                scheduler_id
            from
                ach_transfer
            where
                transaction_id = x.trans_id;

        if x.entrp_id is not null then
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
            )
                select
                    ach_transfer_details_seq.nextval,
                    l_trans_id,
                    group_acc_id,
                    acc_id,
                    ee_amount,
                    er_amount,
                    ee_fee_amount,
                    er_fee_amount,
                    last_updated_by,
                    created_by,
                    sysdate,
                    sysdate
                from
                    ach_transfer_details
                where
                    transaction_id = x.trans_id;

        end if;

    end loop;
end;
/


-- sqlcl_snapshot {"hash":"c6feeaa63adeca6d1257f71c156538710e1f1fca","type":"PROCEDURE","name":"REPROCESS_ACH_MERCHANT_LIMIT","schemaName":"SAMQA","sxml":""}