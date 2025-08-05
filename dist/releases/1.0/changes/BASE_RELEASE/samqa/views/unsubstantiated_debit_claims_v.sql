-- liquibase formatted sql
-- changeset SAMQA:1754374180044 stripComments:false logicalFilePath:BASE_RELEASE\samqa\views\unsubstantiated_debit_claims_v.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/views/unsubstantiated_debit_claims_v.sql:null:3367bf0702a29afa60743619da8014bec6b07413:create

create or replace force editionable view samqa.unsubstantiated_debit_claims_v (
    account_num,
    request_date,
    transaction_number,
    provider,
    amount,
    offset_amount,
    amount_remain,
    category,
    status,
    days_old
) as
    select
        c.acc_num,
        b.creation_date,
        b.claim_id,
        b.prov_name,
        a.amount,
        b.offset_amount,
        ( a.amount - b.offset_amount )   amt_remain,
        account_type,
        'Unsubstantiated'                status,
        trunc(sysdate - b.creation_date) days_old
    from
        payment a,
        claimn  b,
        account c
    where
            a.claimn_id = b.claim_id
        and b.claim_status = 'PAID'
        and c.acc_id = a.acc_id
        and c.account_type in ( 'HRA', 'FSA' )
        and a.reason_code = 13
        and unsubstantiated_flag = 'Y'
        and b.creation_date is not null
        and ( b.substantiation_reason is null
              or b.substantiation_reason <> 'SUPPORT_DOC_RECV' );

