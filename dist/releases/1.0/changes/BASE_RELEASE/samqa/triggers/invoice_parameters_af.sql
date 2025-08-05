-- liquibase formatted sql
-- changeset SAMQA:1754374165845 stripComments:false logicalFilePath:BASE_RELEASE\samqa\triggers\invoice_parameters_af.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/triggers/invoice_parameters_af.sql:null:6023d5ef11381f13f5f7955da753e405cc0a8bfd:create

create or replace editionable trigger samqa.invoice_parameters_af after
    insert or delete or update on samqa.invoice_parameters
    for each row
begin
-- Trigger created by Swamy for Ticket#11619, to capture history for invoice_parameters table 18/05/2023.
    if :old.payment_term <> :new.payment_term
    or :old.invoice_frequency <> :new.invoice_frequency
    or :old.payment_method <> :new.payment_method
    or :old.autopay <> :new.autopay
    or :old.bank_acct_id <> :new.bank_acct_id
    or :old.min_inv_amount <> :new.min_inv_amount
    or :old.invoice_type <> :new.invoice_type
    or :old.rate_plan_id <> :new.rate_plan_id
    or :old.status <> :new.status then
        insert into invoice_parameters_history (
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
            send_invoice_reminder,
            invoice_param_history_id,
            changed_date,
            changed_by
        ) values ( :old.invoice_param_id,
                   :old.entity_id,
                   :old.entity_type,
                   :old.payment_term,
                   :old.invoice_frequency,
                   :old.payment_method,
                   :old.autopay,
                   :old.bank_acct_id,
                   :old.pharmacy_charges_flag,
                   :old.wellness_bonus_flag,
                   :old.creation_date,
                   :old.created_by,
                   :old.last_update_date,
                   :old.last_updated_by,
                   :old.last_invoiced_date,
                   :old.min_inv_amount,
                   :old.invoice_email,
                   :old.billing_name,
                   :old.billing_attn,
                   :old.billing_address,
                   :old.billing_city,
                   :old.billing_zip,
                   :old.billing_state,
                   :old.min_inv_hra_amount,
                   :old.detailed_reporting,
                   :old.sync_address,
                   :old.invoice_type,
                   :old.division_code,
                   :old.product_type,
                   :old.rate_plan_id,
                   :old.status,
                   :old.send_invoice_reminder,
                   invoice_parameters_history_seq.nextval,
                   sysdate,
                   nvl(:new.last_updated_by,
                       :old.created_by) );

    end if;
end;
/

alter trigger samqa.invoice_parameters_af enable;

