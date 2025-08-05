create or replace procedure samqa.insert_inv_parameter as
    l_rate_plan_id number;
    l_trn_combo    number := 0;
    l_fsa_combo    number := 0;
begin
    for x in (
        select
            b.acc_id,
            a.entrp_id,
            a.name,
            b.start_date
        from
            enterprise a,
            account    b
        where
                a.entrp_id = b.entrp_id
            and b.account_type in ( 'HRA', 'FSA' )
            and not exists (
                select
                    *
                from
                    invoice_parameters
                where
                    entity_id = a.entrp_id
            )
    ) loop
        insert into invoice_parameters (
            invoice_param_id,
            entity_id,
            entity_type,
            payment_term,
            invoice_frequency,
            creation_date,
            created_by,
            last_update_date,
            last_updated_by
        )
            select
                invoice_parameters_seq.nextval,
                x.entrp_id,
                'EMPLOYER',
                null,
                'MONTHLY',
                sysdate,
                null,
                sysdate,
                null
            from
                dual
            where
                not exists (
                    select
                        *
                    from
                        invoice_parameters
                    where
                            entity_id = x.entrp_id
                        and entity_type = 'EMPLOYER'
                );

    end loop;
end;
/


-- sqlcl_snapshot {"hash":"10abb9d65033d1f89c9fee9cdc9982b64eee7163","type":"PROCEDURE","name":"INSERT_INV_PARAMETER","schemaName":"SAMQA","sxml":""}