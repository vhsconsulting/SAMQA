create or replace force editionable view samqa.cancelled_contribution_v (
    transaction_id,
    acc_num,
    acc_id,
    bank_acct_id,
    transaction_type,
    transaction_date,
    amount,
    fee_amount,
    total_amount,
    reason_code,
    status,
    error_message,
    processed_date,
    bank_name,
    bank_acct_num,
    bank_routing_num,
    reason_name,
    status_message
) as
    select
        transaction_id,
        acc_num,
        acc_id,
        bank_acct_id,
        transaction_type,
        transaction_date,
        nvl(amount, 0)                                     amount,
        nvl(fee_amount, 0)                                 fee_amount,
        decode(total_amount, 0, amount, total_amount)      total_amount,
        reason_code,
        status,
        error_message,
        to_char(processed_date, 'MM/DD/YYYY')              processed_date,
        display_name                                       bank_name,
        bank_acct_num,
        bank_routing_num,
        decode(transaction_type,
               'D',
               pc_lookups.get_web_expense_type(reason_code),
               (
            select
                fee_name
            from
                fee_names
            where
                fee_code = reason_code
        ))                                                 reason_name,
        decode(status, 9, 'User Cancelled', 3, 'Declined') status_message
    from
        ach_transfer_v xx
    where
            status = 9
        and bankserv_status in ( 'Not Processed', 'Declined', 'User Cancelled' )
    order by
        transaction_date desc;


-- sqlcl_snapshot {"hash":"bf0b66f41b66848668cb2d20e09682dc9e1d5fbc","type":"VIEW","name":"CANCELLED_CONTRIBUTION_V","schemaName":"SAMQA","sxml":""}