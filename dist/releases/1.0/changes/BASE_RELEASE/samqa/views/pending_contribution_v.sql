-- liquibase formatted sql
-- changeset SAMQA:1754374178046 stripComments:false logicalFilePath:BASE_RELEASE\samqa\views\pending_contribution_v.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/views/pending_contribution_v.sql:null:92f3394eff8744617316ea5c09f6afc35ab45559:create

create or replace force editionable view samqa.pending_contribution_v (
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
    status_message,
    scheduler_id
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
        'Pending Approval'                            status_message,
        scheduler_id                                  scheduler_id
    from
        ach_transfer_v
    where
        status in ( 1, 2, 4 )
        and transaction_type = 'C'
        and processed_date is null
    union
    select
        xx.transaction_id,
        xx.acc_num,
        xx.acc_id,
        xx.bank_acct_id,
        xx.transaction_type,
        xx.transaction_date,
        nvl(xx.amount, 0)                                      amount,
        nvl(xx.fee_amount, 0)                                  fee_amount,
        decode(xx.total_amount, 0, xx.amount, xx.total_amount) total_amount,
        xx.reason_code,
        2,
        xx.error_message,
        to_char(xx.processed_date, 'MM/DD/YYYY')               processed_date,
        xx.display_name                                        bank_name,
        xx.bank_acct_num,
        xx.bank_routing_num,
        decode(xx.transaction_type,
               'D',
               pc_lookups.get_web_expense_type(xx.reason_code),
               (
            select
                fee_name
            from
                fee_names
            where
                fee_names.fee_code = xx.reason_code
        ))                                                     reason_name,
        'Pending Transfer',
        xx.scheduler_id                                        scheduler_id
    from
        ach_transfer_v xx,
        income         br
    where
            xx.status = 3
        and br.acc_id = xx.acc_id
        and br.transaction_type = 'P'
        and ( ( br.cc_number like 'BankServ' || xx.transaction_id )
              or ( br.cc_number like 'CNB' || xx.transaction_id ) )
        and xx.transaction_type = 'C'
    order by
        6 asc;

