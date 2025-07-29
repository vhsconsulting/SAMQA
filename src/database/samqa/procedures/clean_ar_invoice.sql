create or replace procedure samqa.clean_ar_invoice (
    p_invoice_id in number
) is
begin
    delete from ar_invoice_dist_plans
    where
        invoice_id = p_invoice_id;

    delete from invoice_distribution_summary
    where
        invoice_id = p_invoice_id;

    delete from ar_invoice_lines
    where
        invoice_id = p_invoice_id;

    delete from ar_invoice
    where
        invoice_id = p_invoice_id;

    delete from ach_transfer
    where
        invoice_id = p_invoice_id;

    delete from employer_payments
    where
        invoice_id = p_invoice_id;

    delete from employer_deposits
    where
        invoice_id = p_invoice_id;

end;
/


-- sqlcl_snapshot {"hash":"1c9385827f3d4c0df4d6dd6c3fd6ad64cdb2b8de","type":"PROCEDURE","name":"CLEAN_AR_INVOICE","schemaName":"SAMQA","sxml":""}