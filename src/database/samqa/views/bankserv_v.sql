create or replace force editionable view samqa.bankserv_v (
    transaction_id,
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
    account_type,
    bankserv_pin
) as
    select
        at.transaction_id,
        at.status,
        at.acc_num,
        c.fee_name,
        nvl(at.total_amount, 0) amount,
        at.bank_routing_num,
        at.bank_acct_num,
        p.first_name            personfname,
        p.last_name             personlname,
        p.address
        || '|'
        || p.city
        || '|'
        || p.state
        || '|'
        || p.zip                personaddress,
        p.phone_day             personphone,
        'N'                     employer,
        at.bank_acct_type,
        at.transaction_date,
        case
            when at.plan_type in ( 'HRA', 'HRP', 'ACO', 'HR4', 'HR5' ) then
                'HRA'
            when at.plan_type in ( 'HRAFSA', 'FSA', 'TRN', 'PKG', 'LPF',
                                   'DCA', 'IIR', 'UA1', 'TP2' ) then
                'FSA'
            else
                account_type
        end                     account_type,
        case
            when at.plan_type in ( 'HRA', 'HRP', 'ACO', 'HR4', 'HR5' ) then
                pc_ach_transfer.get_bankserv_pin('HRA')
            when at.plan_type in ( 'HRAFSA', 'FSA', 'TRN', 'PKG', 'LPF',
                                   'DCA', 'IIR', 'UA1', 'TP2' ) then
                pc_ach_transfer.get_bankserv_pin('FSA')
            when at.account_type in ( 'POP', 'ERISA_WRAP', 'FORM_5500', 'CMP' ) then
                pc_ach_transfer.get_bankserv_pin('COMPLIANCE')
            when at.account_type = 'HSA'   then
                pc_ach_transfer.get_bankserv_pin('HSA')
            when at.account_type = 'COBRA' then
                pc_ach_transfer.get_bankserv_pin('COBRA')
            else
                pc_ach_transfer.get_bankserv_pin(null)
        end                     bankserv_pin
    from
        ach_transfer_v at,
        person         p,
        fee_names      c
    where
            at.pers_id = p.pers_id
        and at.status in ( 1, 2 )
        and trunc(transaction_date) <= trunc(sysdate)
        and at.bank_status = 'A'
        and at.transaction_type = 'C'
        and nvl(at.total_amount, 0) > 0
        and c.fee_code = at.reason_code
    union
    select
        at.transaction_id,
        at.status,
        at.acc_num,
        c.fee_name,
        nvl(at.total_amount, 0) amount,
        at.bank_routing_num,
        at.bank_acct_num,
        e.name                  empname,
        null,
        e.address
        || '|'
        || e.city
        || '|'
        || e.state
        || '|'
        || e.zip                empaddress,
        e.entrp_phones          as empphone,
        'Y'                     employer,
        at.bank_acct_type,
        at.transaction_date,
        case
            when at.plan_type in ( 'HRA', 'HRP', 'ACO', 'HR4', 'HR5' ) then
                'HRA'
            when at.plan_type in ( 'HRAFSA', 'FSA', 'TRN', 'PKG', 'LPF',
                                   'DCA', 'IIR', 'UA1', 'TP2' ) then
                'FSA'
            else
                account_type
        end                     account_type,
        case
            when at.plan_type in ( 'HRA', 'HRP', 'ACO', 'HR4', 'HR5' ) then
                pc_ach_transfer.get_bankserv_pin('HRA')
            when at.plan_type in ( 'HRAFSA', 'FSA', 'TRN', 'PKG', 'LPF',
                                   'DCA', 'IIR', 'UA1', 'TP2' ) then
                pc_ach_transfer.get_bankserv_pin('FSA')
            when at.account_type in ( 'POP', 'ERISA_WRAP', 'FORM_5500', 'CMP' ) then
                pc_ach_transfer.get_bankserv_pin('COMPLIANCE')
            when at.account_type = 'COBRA' then
                pc_ach_transfer.get_bankserv_pin('COBRA')
            when at.account_type = 'HSA'   then
                pc_ach_transfer.get_bankserv_pin('HSA')
            else
                pc_ach_transfer.get_bankserv_pin(null)
        end                     bankserv_pin
    from
        ach_transfer_v at,
        enterprise     e,
        fee_names      c
    where
            at.entrp_id = e.entrp_id
        and at.status in ( 1, 2 )
        and trunc(transaction_date) <= trunc(sysdate)
        and at.transaction_type = 'C'
        and at.bank_status = 'A'
        and nvl(at.total_amount, 0) > 0
        and c.fee_code = at.reason_code
    union
    select
        at.transaction_id,
        at.status,
        at.acc_num,
        c.reason_name,
        nvl(at.total_amount, 0)                amount,
        at.bank_routing_num,
        at.bank_acct_num,
        e.name                                 empname,
        null,
        e.address
        || '|'
        || e.city
        || '|'
        || e.state
        || '|'
        || e.zip                               empaddress,
        e.entrp_phones                         as empphone,
        'Y'                                    employer,
        at.bank_acct_type,
        at.transaction_date,
        case
            when at.plan_type in ( 'HRA', 'HRP', 'ACO', 'HR4', 'HR5' ) then
                'HRA'
            when at.plan_type in ( 'HRAFSA', 'FSA', 'TRN', 'PKG', 'LPF',
                                   'DCA', 'IIR', 'UA1', 'TP2' ) then
                'FSA'
            else
                account_type
        end                                    account_type,
        pc_ach_transfer.get_bankserv_pin(null) bankserv_pin
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
    order by
        3,
        1;


-- sqlcl_snapshot {"hash":"3134d12634cd567a2858f5b1259ac1111028273e","type":"VIEW","name":"BANKSERV_V","schemaName":"SAMQA","sxml":""}