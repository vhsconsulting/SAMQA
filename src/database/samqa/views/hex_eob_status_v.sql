create or replace force editionable view samqa.hex_eob_status_v (
    eob_id,
    created_by,
    eob_status,
    date_of_payment,
    amount
) as
    select
        eob_id,
        a.created_by,
        nvl(
            case
                when eob_status_code in('PENDING_APPROVAL', 'PROCESSED', 'PENDING_REVIW', 'PENDING_OTHER_INSURANCE', 'PENDING') then
                    '11' --Processing now
                when eob_status_code = 'PENDING_DOC' then
                    '12' -- Can't be closed until document is not sent
                when eob_status_code in('APPROVED', 'APPROVED_FOR_CHEQUE', 'APPROVED_TO_DEDUCITBLE', 'READY_TO_PAY') then
                    '13' -- Reimbursement process started
                when eob_status_code = 'PAID' then
                    '22' -- Paid Reimbursement was accepted and paid
                when eob_status_code = 'PARTIALLY_PAID' then
                    '23' -- Reimbursement or payment was done in part
                when
                    eob_status = 'DENIED'
                    and account_type = 'FSA'
                then
                    '24' --FSA reimbursement request was denied
                when
                    eob_status = 'DENIED'
                    and account_type = 'HSA'
                then
                    '25' --HSA reimbursement request was denied
                when
                    eob_status = 'DENIED'
                    and account_type = 'HRA'
                then
                    '26' --HRA reimbursement request was denied
                when
                    eob_status = 'APPROVED_NO_FUNDS'
                    and account_type <> 'HSA'
                then
                    '27' -- Waiting for Employer to fund account
                when
                    eob_status = 'APPROVED_NO_FUNDS'
                    and account_type = 'HSA'
                then
                    '28' -- Waiting for you to fund the account
                when eob_status_code = 'DECLINED' then
                    '29' -- Declined due to incorrect information, can be re-tried
            end, '5')                             eob_status,
        to_char(c.paid_date, 'MM/DD/YYYY') paid_date,
        c.amount
    from
        eob_header a,
        account    b,
        payment    c
    where
            a.acc_id = b.acc_id
        and c.claimn_id = a.claim_id;


-- sqlcl_snapshot {"hash":"c51b51378dd0dc6f93955c7e5469ad2a4038cf18","type":"VIEW","name":"HEX_EOB_STATUS_V","schemaName":"SAMQA","sxml":""}