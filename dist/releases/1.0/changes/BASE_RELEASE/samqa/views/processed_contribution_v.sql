-- liquibase formatted sql
-- changeset SAMQA:1754374178380 stripComments:false logicalFilePath:BASE_RELEASE\samqa\views\processed_contribution_v.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/views/processed_contribution_v.sql:null:8a1ef6d2c7d55a395987f2d673626316f8fdc291:create

create or replace force editionable view samqa.processed_contribution_v (
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
        nvl(amount, 0)                                amount,
        nvl(fee_amount, 0)                            fee_amount,
        decode(total_amount, 0, amount, total_amount) total_amount,
        reason_code,
        status,
        error_message,
        to_char(processed_date, 'MM/DD/YYYY')         processed_date,
        display_name                                  bank_name,
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
        ))                                            reason_name,
        null                                          status_message
    from
        ach_transfer_v xx
    where
            status = 3
        and transaction_type = 'C'
        and bankserv_status = 'Approved'
        and not exists (
            select
                *
            from
                income br
            where
                    br.acc_id = xx.acc_id
                and br.transaction_type = 'P'
                and ( ( br.cc_number like 'BankServ' || xx.transaction_id )
                      or ( br.cc_number like 'CNB' || xx.transaction_id ) )
        )
        and exists (
            select
                *
            from
                income br
            where
                    br.acc_id = xx.acc_id
                and ( ( br.cc_number like 'BankServ' || xx.transaction_id )
                      or ( br.cc_number like 'CNB' || xx.transaction_id ) )
        )
    order by
        transaction_date desc;

