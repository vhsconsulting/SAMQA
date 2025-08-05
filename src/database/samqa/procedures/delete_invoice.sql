create or replace procedure samqa.delete_invoice (
    p_invoice_id in number
) as
begin
    for x in (
        select
            entity_id,
            invoice_id
        from
            ar_invoice
        where
            invoice_id = p_invoice_id
    ) loop
        delete from ar_invoice_lines
        where
            invoice_id = x.invoice_id;

        delete from ar_invoice
        where
            invoice_id = x.invoice_id;

        delete from ar_invoice_dist_plans
        where
            invoice_id = x.invoice_id;

        delete from invoice_distribution_summary
        where
            invoice_id = x.invoice_id;

        delete from invoice_parameters
        where
            entity_id = x.entity_id;

        delete from rate_plan_detail
        where
            rate_plan_id in (
                select
                    rate_plan_id
                from
                    rate_plans
                where
                    entity_id = x.entity_id
            );

        delete from rate_plans
        where
            entity_id = x.entity_id;

    end loop;
end;
/


-- sqlcl_snapshot {"hash":"c62e352a3e71a366c7e59bfd40e8f76364fd5ba5","type":"PROCEDURE","name":"DELETE_INVOICE","schemaName":"SAMQA","sxml":""}