create or replace force editionable view samqa.incomplete_account_funds_v (
    acc_num,
    start_date,
    data_entry_date,
    first_name,
    last_name,
    employer_name,
    refund_amount,
    sales_rep,
    account_manager,
    complete_flag
) as
    select
        a.acc_num,
        a.start_date,
        a.reg_date                                                                               "Data Entry Date",
        c.first_name,
        c.last_name,
        pc_entrp.get_entrp_name(c.entrp_id),
        sum(nvl(amount, 0) + nvl(amount_add, 0) + nvl(ee_fee_amount, 0) + nvl(er_fee_amount, 0)) "Refund Amount",
        pc_account.get_salesrep_name(a.salesrep_id)                                              "Salesrep ",
        pc_account.get_salesrep_name(a.am_id)                                                    "Account Manager ",
        decode(complete_flag, 0, 'Account Incomplete', 'Account Complete')                       "Setup Status"
    from
        account a,
        person  c,
        income  b
    where
            account_status = 3
        and c.pers_id = a.pers_id
        and a.acc_id = b.acc_id (+)
        and nvl(a.blocked_flag, 'N') <> 'Y'
    group by
        a.acc_num,
        a.start_date,
        a.reg_date,
        c.first_name,
        c.last_name,
        c.entrp_id,
        a.salesrep_id,
        a.am_id,
        complete_flag
    order by
        6,
        8;


-- sqlcl_snapshot {"hash":"f4cc46e3b7ee50f9afadd8aa4f96080c450f614e","type":"VIEW","name":"INCOMPLETE_ACCOUNT_FUNDS_V","schemaName":"SAMQA","sxml":""}