create or replace procedure samqa.close_qb_account (
    p_pers_id   number,
    p_term_date date,
    p_user_id   number
) is
begin

-- Terminate all QB accounts
    update account
    set
        end_date = p_term_date,
        account_status = 4,
        last_update_date = sysdate,
        last_updated_by = p_user_id
    where
            pers_id = p_pers_id
        and account_status = 1
        and end_date is null;

--	Update the plans elections status
    update plan_elections
    set
        status = decode(status, 'E', 'TE', 'P', 'TP',
                        'PR', 'TP', status),
        termination_date = p_term_date,
        termination_reason = 'EMPLOYER_TERMED',
        last_update_date = sysdate,
        last_updated_by = p_user_id
    where
            pers_id = p_pers_id
        and status in ( 'P', 'PR', 'E', 'E45' );

    pc_log.log_error('CLOSE_QB_ACCOUNTS', 'no of plan elections terminated: ' || sql%rowcount);

--Update the invoice parameter and rate plans effective end date and also status. ( end dating premium setup)
    update invoice_parameters
    set
        status = 'I'--, NOTE = 'Employer closed the account'
        ,
        last_update_date = sysdate,
        last_updated_by = p_user_id
    where
            entity_type = 'PERSON'
        and entity_id = p_pers_id
        and status = 'A';

    pc_log.log_error('CLOSE_QB_ACCOUNTS', 'No of invoice parameters records affected: ' || sql%rowcount);
    update rate_plan_detail
    set
        effective_end_date = p_term_date,
        last_update_date = sysdate,
        last_updated_by = p_user_id
    where
        ( effective_end_date is null
          or effective_end_date > sysdate )
        and rate_plan_id in (
            select
                rate_plan_id
            from
                rate_plans
            where
                    entity_type = 'PERSON'
                and entity_id = p_pers_id
        );

    pc_log.log_error('CLOSE_QB_ACCOUNTS', 'No of rate_plan_details records affected: ' || sql%rowcount);
    update rate_plans
    set
        status = 'I',
        effective_end_date = p_term_date,
        last_update_date = sysdate,
        last_updated_by = p_user_id
    where
            entity_type = 'PERSON'
        and entity_id = p_pers_id
        and status = 'A';

-- Cancel the invoices.
    for i in (
        select
            invoice_id
        from
            ar_invoice
        where
                entity_type = 'PERSON'
            and invoice_reason = 'PREMIUM'
            and entity_id = p_pers_id
            and status in ( '¿GENERATED', 'PROCESSED' )
    ) loop
        pc_invoice.void_invoice(i.invoice_id, p_user_id, 'EMPLOYER_TERMED', null, 'CANCELLED');
    end loop;

end close_qb_account;
/


-- sqlcl_snapshot {"hash":"8ca7e5c14222bd415a65f7c1ce0d3e16510e670a","type":"PROCEDURE","name":"CLOSE_QB_ACCOUNT","schemaName":"SAMQA","sxml":""}