create or replace procedure samqa.schedule_payment_plan (
    p_payment_start_date date,
    p_source_claim_id    in number,
    p_no_of_months       in number
) is
    l_claim_id       number;
    l_payment_reg_id number;
begin
    for x in (
        select
            add_months(p_payment_start_date, rownum - 1) claim_date
        from
            all_objects
        where
            rownum < p_no_of_months + 1
    ) loop
        select
            doc_seq.nextval
        into l_claim_id
        from
            dual;

        select
            payment_register_seq.nextval
        into l_payment_reg_id
        from
            dual;

        insert into payment_register (
            payment_register_id,
            batch_number,
            acc_num,
            acc_id,
            pers_id,
            provider_name,
            vendor_id,
            vendor_orig_sys,
            claim_code,
            claim_id,
            trans_date,
            claim_amount,
            claim_type,
            peachtree_interfaced,
            claim_error_flag,
            insufficient_fund_flag,
            pay_reason,
            memo,
            creation_date,
            created_by,
            last_update_date,
            last_updated_by,
            entrp_id,
            note,
            patient_name
        )
            select
                l_payment_reg_id,
                batch_number,
                acc_num,
                acc_id,
                pers_id,
                provider_name,
                vendor_id,
                vendor_orig_sys,
                claim_code,
                l_claim_id,
                x.claim_date,
                claim_amount,
                claim_type,
                peachtree_interfaced,
                claim_error_flag,
                insufficient_fund_flag,
                pay_reason,
                memo,
                sysdate,
                created_by,
                sysdate,
                last_updated_by,
                entrp_id,
                note,
                patient_name
            from
                payment_register
            where
                claim_id = p_source_claim_id;

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
            note,
            claim_status,
            claim_date,
            vendor_id,
            bank_acct_id,
            pay_reason
        )
            select
                l_claim_id,
                pers_id,
                pers_patient,
                claim_code,
                prov_name,
                claim_date_start,
                claim_date_end,
                service_status,
                claim_amount,
                0,
                claim_amount,
                note,
                'PENDING_APPROVAL',
                x.claim_date,
                vendor_id,
                bank_acct_id,
                pay_reason
            from
                claimn
            where
                claim_id = p_source_claim_id;

    end loop;
end;
/


-- sqlcl_snapshot {"hash":"81eeaee3ec020906f76d9d81cd00ca5260cd7508","type":"PROCEDURE","name":"SCHEDULE_PAYMENT_PLAN","schemaName":"SAMQA","sxml":""}