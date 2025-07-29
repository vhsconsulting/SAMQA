create or replace procedure samqa.gp_scheduler as
    l_file_name varchar2(3200);
begin
    pc_sam_gp_intgrtn.gp_customer_account(l_file_name);
    pc_sam_gp_intgrtn.gp_vendor_account(l_file_name);
    pc_sam_gp_intgrtn.gp_check_receipt(l_file_name);
    pc_sam_gp_intgrtn.gp_ach_receipt(l_file_name);
    pc_sam_gp_intgrtn.gp_hsa_fee(l_file_name);
    pc_sam_gp_intgrtn.gp_check_payment(l_file_name);
    pc_sam_gp_intgrtn.gp_ach_payment(l_file_name);
    pc_sam_gp_intgrtn.gp_debit_card_payment(l_file_name);
    pc_sam_gp_intgrtn.gp_invoices(l_file_name);
    pc_sam_gp_intgrtn.gp_hsa_interest(l_file_name);
end;
/


-- sqlcl_snapshot {"hash":"7c81eebdc026f08efb7d6ddbff9252fdc81a1a58","type":"PROCEDURE","name":"GP_SCHEDULER","schemaName":"SAMQA","sxml":""}