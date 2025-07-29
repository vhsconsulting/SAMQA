create or replace procedure samqa.cleanup_duplicate (
    p_cobra_payment_id in number
) as
begin
    for x in (
        select
            r.payment_register_id,
            cobra_disbursement_id,
            c.status,
            c.check_number,
            c.check_date,
            a.employer_payment_id
        from
            employer_payments a,
            checks            c,
            payment_register  r
        where
                cobra_disbursement_id = p_cobra_payment_id
            and a.entrp_id = r.entrp_id
            and a.payment_register_id = r.payment_register_id
            and c.entity_id = r.payment_register_id
            and c.entity_type = 'EMPLOYER_PAYMENTS'
    ) loop
        if x.status = 'MAILED' then
            update employer_payments
            set
                check_date = x.check_date
            where
                    cobra_disbursement_id = x.cobra_disbursement_id
                and employer_payment_id = x.employer_payment_id;

        else
            update employer_payments
            set
                check_date = null
            where
                    cobra_disbursement_id = x.cobra_disbursement_id
                and employer_payment_id = x.employer_payment_id;

        end if;
    end loop;
end;
/


-- sqlcl_snapshot {"hash":"dc8b46db2b56d1a022ebef473887c38e5addd565","type":"PROCEDURE","name":"CLEANUP_DUPLICATE","schemaName":"SAMQA","sxml":""}