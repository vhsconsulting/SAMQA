-- liquibase formatted sql
-- changeset SAMQA:1754374169833 stripComments:false logicalFilePath:BASE_RELEASE\samqa\views\claim_detail_v.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/views/claim_detail_v.sql:null:79c3b1f22fbe61cd4e6023578ae2c70ad03ba50b:create

create or replace force editionable view samqa.claim_detail_v (
    acc_num,
    account_type,
    claim_id,
    service_code,
    tax_code,
    service_price,
    service_count,
    service_status,
    service_name,
    sure_amount,
    note,
    claim_detail_id,
    service_date,
    service_provider,
    creation_date,
    created_by,
    last_update_date,
    last_updated_by,
    service_end_date,
    patient_dep_name,
    medical_code,
    eob_detail_id,
    state_tax
) as
    select
        c.acc_num,
        c.account_type,
        a.claim_id,
        a.service_code,
        a.tax_code,
        a.service_price,
        a.service_count,
        a.service_status,
        a.service_name,
        a.sure_amount,
        a.note,
        a.claim_detail_id,
        to_char(a.service_date, 'MM/DD/YYYY')     service_date,
        a.service_provider,
        a.creation_date,
        a.created_by,
        a.last_update_date,
        a.last_updated_by,
        to_char(a.service_end_date, 'MM/DD/YYYY') service_end_date,
        a.patient_dep_name,
        a.tax_code                                medical_code,
        a.eob_detail_id,
        a.state_tax
    from
        claim_detail a,
        claimn       b,
        account      c
    where
            a.claim_id = b.claim_id
        and b.pers_id = c.pers_id;

