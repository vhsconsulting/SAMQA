-- liquibase formatted sql
-- changeset SAMQA:1754374143884 stripComments:false logicalFilePath:BASE_RELEASE\samqa\procedures\gp_scheduler.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/procedures/gp_scheduler.sql:null:7c81eebdc026f08efb7d6ddbff9252fdc81a1a58:create

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

