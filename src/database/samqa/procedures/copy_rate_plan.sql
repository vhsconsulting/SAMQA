create or replace procedure samqa.copy_rate_plan (
    p_rate_plan_id  in number,
    p_division_code in varchar2
) is
    l_rate_plan_id number;
begin
    insert into rate_plans (
        rate_plan_id,
        rate_plan_name,
        entity_type,
        entity_id,
        status,
        note,
        effective_date,
        effective_end_date,
        creation_date,
        created_by,
        last_update_date,
        last_updated_by,
        rate_plan_type,
        sales_team_member_id,
        division_invoicing,
        account_type,
        division_code
    )
        select
            rate_plans_seq.nextval,
            rate_plan_name,
            entity_type,
            entity_id,
            status,
            note,
            effective_date,
            effective_end_date,
            sysdate,
            0,
            sysdate,
            0,
            rate_plan_type,
            sales_team_member_id,
            division_invoicing,
            account_type,
            p_division_code
        from
            rate_plans
        where
            rate_plan_id = p_rate_plan_id;

    l_rate_plan_id := rate_plans_seq.currval;
    insert into invoice_parameters (
        invoice_param_id,
        entity_id,
        entity_type,
        payment_term,
        invoice_frequency,
        payment_method,
        autopay,
        bank_acct_id,
        pharmacy_charges_flag,
        wellness_bonus_flag,
        creation_date,
        created_by,
        last_update_date,
        last_updated_by,
        last_invoiced_date,
        min_inv_amount,
        invoice_email,
        billing_name,
        billing_attn,
        billing_address,
        billing_city,
        billing_zip,
        billing_state,
        min_inv_hra_amount,
        detailed_reporting,
        sync_address,
        invoice_type,
        division_code,
        product_type,
        rate_plan_id,
        status,
        send_invoice_reminder
    )
        select
            invoice_parameters_seq.nextval,
            entity_id,
            entity_type,
            payment_term,
            invoice_frequency,
            payment_method,
            autopay,
            bank_acct_id,
            pharmacy_charges_flag,
            wellness_bonus_flag,
            sysdate,
            0,
            sysdate,
            0,
            last_invoiced_date,
            min_inv_amount,
            invoice_email,
            billing_name,
            billing_attn,
            billing_address,
            billing_city,
            billing_zip,
            billing_state,
            min_inv_hra_amount,
            detailed_reporting,
            sync_address,
            invoice_type,
            p_division_code,
            product_type,
            l_rate_plan_id,
            status,
            send_invoice_reminder
        from
            invoice_parameters
        where
            rate_plan_id = p_rate_plan_id;

    for x in (
        select
            invoice_type,
            invoice_param_id
        from
            invoice_parameters
        where
            rate_plan_id = l_rate_plan_id
    ) loop
        insert into rate_plan_detail (
            rate_plan_detail_id,
            rate_plan_id,
            coverage_type,
            calculation_type,
            minimum_range,
            maximum_range,
            description,
            rate_code,
            rate_plan_cost,
            creation_date,
            created_by,
            last_update_date,
            last_updated_by,
            rate_basis,
            effective_date,
            effective_end_date,
            one_time_flag,
            charged_to,
            invoice_param_id
        )
            select
                rate_plan_detail_seq.nextval,
                rate_plans_seq.currval,
                a.coverage_type,
                a.calculation_type,
                a.minimum_range,
                a.maximum_range,
                a.description,
                a.rate_code,
                a.rate_plan_cost,
                sysdate,
                0,
                sysdate,
                0,
                a.rate_basis,
                a.effective_date,
                a.effective_end_date,
                a.one_time_flag,
                a.charged_to,
                x.invoice_param_id
            from
                rate_plan_detail   a,
                invoice_parameters i
            where
                    a.rate_plan_id = i.rate_plan_id
                and i.invoice_type = x.invoice_type
                and a.rate_plan_id = p_rate_plan_id;

    end loop;

end;
/


-- sqlcl_snapshot {"hash":"f10be0a412897c984afcac2194e3fe3cec9995ef","type":"PROCEDURE","name":"COPY_RATE_PLAN","schemaName":"SAMQA","sxml":""}