create or replace force editionable view samqa.ach_nacha_v (
    transaction_id,
    claim_id,
    status,
    acc_num,
    fee_name,
    amount,
    bank_routing_num,
    bank_acct_num,
    personfname,
    personlname,
    personaddress,
    personphone,
    employer,
    bank_acct_type,
    transaction_date,
    transaction_type,
    account_type,
    plan_type,
    std_entry_class_code,
    service_class
) as
    select
        at.transaction_id,
        at.claim_id,
        at.status,
        at.acc_num,
        c.fee_name,
        nvl(at.total_amount, 0)                        amount,
        at.bank_routing_num,
        regexp_replace(at.bank_acct_num, '[^0-9]', '') bank_acct_num,
        p.first_name                                   personfname,
        p.last_name                                    personlname,
        p.address
        || '|'
        || p.city
        || '|'
        || p.state
        || '|'
        || p.zip                                       personaddress,
        p.phone_day                                    personphone,
        'N'                                            employer,
        at.bank_acct_type,
        at.transaction_date,
        at.transaction_type,
        case
            when at.plan_type in ( 'HRA', 'HRP', 'ACO', 'HR4', 'HR5' ) then
                'HRA'
            when at.plan_type in ( 'HRAFSA', 'FSA', 'TRN', 'PKG', 'LPF',
                                   'DCA', 'IIR', 'UA1', 'TP2' ) then
                'FSA'
            else
                account_type
        end                                            account_type,
        at.plan_type,
        'PPD'                                          std_entry_class_code,  -- Added by Joshi for 11701
        '225'                                          service_class        -- Added by Swamy for Ticket#Nacha
    from
        ach_transfer_v at,
        person         p,
        fee_names      c
    where
            at.pers_id = p.pers_id
        and at.status in ( 1, 2 )
        and trunc(transaction_date) <= trunc(sysdate)
        and at.transaction_type = 'C'
        and nvl(at.total_amount, 0) > 0
        and c.fee_code = at.reason_code
        and at.bank_status = 'A'
    union
/*Individual Disbursements for HSA */
    select
        at.transaction_id,
        at.claim_id,
        at.status,
        at.acc_num,
        'Disbursement',
        nvl(at.total_amount, 0)                        amount,
        at.bank_routing_num,
        regexp_replace(at.bank_acct_num, '[^0-9]', '') bank_acct_num,
        p.first_name                                   personfname,
        p.last_name                                    personlname,
        p.address
        || '|'
        || p.city
        || '|'
        || p.state
        || '|'
        || p.zip                                       personaddress,
        p.phone_day                                    personphone,
        'N'                                            employer,
        at.bank_acct_type,
        at.transaction_date,
        at.transaction_type,
        case
            when at.plan_type in ( 'HRA', 'HRP', 'ACO', 'HR4', 'HR5' ) then
                'HRA'
            when at.plan_type in ( 'HRAFSA', 'FSA', 'TRN', 'PKG', 'LPF',
                                   'DCA', 'IIR', 'UA1', 'TP2' ) then
                'FSA'
            else
                at.account_type
        end                                            account_type,
        at.plan_type,
        'PPD'                                          std_entry_class_code,  -- Added by Joshi for 11701
        '220'                                          service_class        -- Added by Swamy for Ticket#Nacha
    from
        ach_transfer_v at,
        person         p
    where
            at.pers_id = p.pers_id
        and at.status in ( 1, 2 )
        and trunc(transaction_date) <= trunc(sysdate)
        and at.transaction_type = 'D'
        and nvl(at.total_amount, 0) > 0
        and pc_account.new_acc_balance(at.acc_id) > 0 --Balance greater than zero
        and pc_account.new_acc_balance(at.acc_id) > nvl(at.total_amount, 0) -- Balnace greater than claim amount
        and at.account_type = 'HSA'
        and at.bank_status = 'A'
    union
  /*Individual Disbursements for FSA/HRA*/
    select
        at.transaction_id,
        at.claim_id,
        at.status,
        at.acc_num,
        'Disbursement',
        nvl(at.total_amount, 0)                        amount,
        at.bank_routing_num,
        regexp_replace(at.bank_acct_num, '[^0-9]', '') bank_acct_num,
        p.first_name                                   personfname,
        p.last_name                                    personlname,
        p.address
        || '|'
        || p.city
        || '|'
        || p.state
        || '|'
        || p.zip                                       personaddress,
        p.phone_day                                    personphone,
        'N'                                            employer,
        at.bank_acct_type,
        at.transaction_date,
        at.transaction_type,
        case
            when at.plan_type in ( 'HRA', 'HRP', 'ACO', 'HR4', 'HR5' ) then
                'HRA'
            when at.plan_type in ( 'HRAFSA', 'FSA', 'TRN', 'PKG', 'LPF',
                                   'DCA', 'IIR', 'UA1', 'TP2' ) then
                'FSA'
            else
                at.account_type
        end                                            account_type,
        at.plan_type,
        'PPD'                                          std_entry_class_code,  -- Added by Joshi for 11701
        '220'                                          service_class        -- Added by Swamy for Ticket#Nacha
    from
        ach_transfer_v            at,
        person                    p,
        ben_plan_enrollment_setup bp,
        claimn                    e
    where
            at.pers_id = p.pers_id
        and at.status in ( 1, 2 )
        and trunc(transaction_date) <= trunc(sysdate)
        and at.transaction_type = 'D'
        and at.account_type in ( 'FSA', 'HRA' )
        and nvl(at.total_amount, 0) > 0
        and bp.acc_id = at.acc_id
        and e.claim_id = at.claim_id
        and e.plan_start_date = bp.plan_start_date
        and e.plan_end_date = bp.plan_end_date
        and at.plan_type = bp.plan_type
        and pc_account.acc_balance(at.acc_id, bp.plan_start_date, bp.plan_end_date, at.account_type, at.plan_type) > 0
        and at.bank_status = 'A'
    union
/*Employer Disbursements */
    select
        at.transaction_id,
        at.claim_id,
        at.status,
        at.acc_num,
        'Disbursement',
        nvl(at.total_amount, 0)                        amount,
        at.bank_routing_num,
        regexp_replace(at.bank_acct_num, '[^0-9]', '') bank_acct_num,
        e.name,
        null                                           personlname,
        e.address
        || '|'
        || e.city
        || '|'
        || e.state
        || '|'
        || e.zip                                       personaddress,
        e.entrp_phones                                 personphone,
        'Y'                                            employer,
        at.bank_acct_type,
        at.transaction_date,
        at.transaction_type,
        case
            when at.plan_type in ( 'HRA', 'HRP', 'ACO', 'HR4', 'HR5' ) then
                'HRA'
            when at.plan_type in ( 'HRAFSA', 'FSA', 'TRN', 'PKG', 'LPF',
                                   'DCA', 'IIR', 'UA1', 'TP2' ) then
                'FSA'
            else
                account_type
        end                                            account_type,
        at.plan_type,
        'CCD'                                          std_entry_class_code, -- Added by Joshi for 11701
        '220'                                          service_class        -- Added by Swamy for Ticket#Nacha
    from
        ach_transfer_v at,
        enterprise     e
    where
        at.pers_id is null
        and at.status in ( 1, 2 )
        and trunc(transaction_date) <= trunc(sysdate)
        and at.transaction_type = 'D'
        and nvl(at.total_amount, 0) > 0
        and at.entrp_id = e.entrp_id
        and at.bank_status = 'A'
    union
  /*Employer Contributions */
    select
        at.transaction_id,
        at.claim_id,
        at.status,
        at.acc_num,
        'Contribution',
        nvl(at.total_amount, 0)                        amount,
        at.bank_routing_num,
        regexp_replace(at.bank_acct_num, '[^0-9]', '') bank_acct_num,
        e.name,
        null                                           personlname,
        e.address
        || '|'
        || e.city
        || '|'
        || e.state
        || '|'
        || e.zip                                       personaddress,
        e.entrp_phones                                 personphone,
        'Y'                                            employer,
        at.bank_acct_type,
        at.transaction_date,
        at.transaction_type,
        case
            when at.plan_type in ( 'HRA', 'HRP', 'ACO', 'HR4', 'HR5' ) then
                'HRA'
             -- WHEN At.Plan_Type IN ('HRAFSA','FSA','TRN','PKG','LPF','DCA','IIR','UA1','TP2') -- commented by Joshi for 10847
            when at.plan_type in ( 'FSA', 'TRN', 'PKG', 'LPF', 'DCA',
                                   'IIR', 'UA1', 'TP2' ) then
                'FSA'
            when at.plan_type = 'HRAFSA' -- Added by Joshi for  10847
             then
                pc_invoice.get_product_type(at.invoice_id)
            else
                account_type
        end                                            account_type,
        at.plan_type,
        'CCD'                                          std_entry_class_code,
        '225'                                          service_class        -- Added by Swamy for Ticket#Nacha
    from
        ach_transfer_v at,
        enterprise     e
    where
        at.pers_id is null
        and at.status in ( 1, 2 )
        and trunc(transaction_date) <= trunc(sysdate)
        and at.transaction_type = 'C'
        and nvl(at.total_amount, 0) > 0
        and at.entrp_id = e.entrp_id
        and at.bank_status = 'A'
    union
  /*Fee payment transactions */
    select
        at.transaction_id,
        at.claim_id,
        at.status,
        at.acc_num,
        'Fee Payment',
        nvl(at.total_amount, 0)                        amount,
        at.bank_routing_num,
        regexp_replace(at.bank_acct_num, '[^0-9]', '') bank_acct_num,
        e.name,
        null                                           personlname,
        e.address
        || '|'
        || e.city
        || '|'
        || e.state
        || '|'
        || e.zip                                       personaddress,
        e.entrp_phones                                 personphone,
        'Y'                                            employer,
        at.bank_acct_type,
        at.transaction_date,
        at.transaction_type,
        case
            when at.plan_type in ( 'HRA', 'HRP', 'ACO', 'HR4', 'HR5' ) then
                'HRA'
            when at.plan_type in ( 'HRAFSA', 'FSA', 'TRN', 'PKG', 'LPF',
                                   'DCA', 'IIR', 'UA1', 'TP2' ) then
                'FSA'
            else
                account_type
        end                                            account_type,
        at.plan_type,
        'CCD'                                          std_entry_class_code,
        '225'                                          service_class        -- Added by Swamy for Ticket#Nacha
    from
        ach_transfer_v at,
        enterprise     e,
        pay_reason     c
    where
            at.entrp_id = e.entrp_id
        and at.status in ( 1, 2 )
        and trunc(transaction_date) <= trunc(sysdate)
        and at.transaction_type = 'F'
        and at.bank_status = 'A'
        and nvl(at.total_amount, 0) > 0
        and c.reason_code = at.reason_code
    union  -- Added by Joshi for 12748- Sprint 59: ACH Pull for FSA/HRA Claims
    select
        at.transaction_id,
        at.claim_id,
        at.status,
        at.acc_num,
        'Contribution',
        nvl(at.total_amount, 0)                        amount,
        at.bank_routing_num,
        regexp_replace(at.bank_acct_num, '[^0-9]', '') bank_acct_num,
        p.first_name                                   personfname,
        p.last_name                                    personlname,
        p.address
        || '|'
        || p.city
        || '|'
        || p.state
        || '|'
        || p.zip                                       personaddress,
        p.phone_day                                    personphone,
        'N'                                            employer,
        at.bank_acct_type,
        at.transaction_date,
        at.transaction_type,
        case
            when at.plan_type in ( 'HRA', 'HRP', 'ACO', 'HR4', 'HR5' ) then
                'HRA'
            when at.plan_type in ( 'HRAFSA', 'FSA', 'TRN', 'PKG', 'LPF',
                                   'DCA', 'IIR', 'UA1', 'TP2' ) then
                'FSA'
            else
                at.account_type
        end                                            account_type,
        at.plan_type,
        'PPD'                                          std_entry_class_code,  -- Added by Joshi for 11701
        '225'                                          service_class        -- Added by Swamy for Ticket#Nacha
    from
        ach_transfer_v at,
        person         p,
        claimn         e
    where
            at.pers_id = p.pers_id
        and at.status in ( 1, 2 )
        and trunc(transaction_date) <= trunc(sysdate)
        and at.transaction_type = 'P'
        and at.account_type in ( 'FSA', 'HRA' )
        and nvl(at.total_amount, 0) > 0
        and e.claim_id = at.claim_id
        and at.bank_status = 'A';


-- sqlcl_snapshot {"hash":"3074bb8599a8a2eccdedbaad8da1b5cb59448c1b","type":"VIEW","name":"ACH_NACHA_V","schemaName":"SAMQA","sxml":""}