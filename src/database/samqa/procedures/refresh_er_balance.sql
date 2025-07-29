create or replace procedure samqa.refresh_er_balance (
    p_entrp_id in number
) is
begin
    delete from employer_payments
    where
        transaction_source in ( 'PENDING_CHECK', 'PENDING_ACH', 'CLAIM_PAYMENT' )
        and entrp_id = p_entrp_id;

    pc_employer_fin.create_employer_payment(p_entrp_id, null);
end refresh_er_balance;
/


-- sqlcl_snapshot {"hash":"81980eeb78f1011b0e01d38f4dfd98d04c39a0ec","type":"PROCEDURE","name":"REFRESH_ER_BALANCE","schemaName":"SAMQA","sxml":""}