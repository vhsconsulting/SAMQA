-- liquibase formatted sql
-- changeset SAMQA:1754374167989 stripComments:false logicalFilePath:BASE_RELEASE\samqa\views\agile_payments_v.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/views/agile_payments_v.sql:null:0e06206cebbcf3b27671d2fe7bf6054b6a3ae3e5:create

create or replace force editionable view samqa.agile_payments_v (
    transaction_id,
    status,
    acc_num,
    fee_name,
    amount,
    bank_routing_num,
    bank_acct_num,
    personfname,
    personlname,
    employer_name,
    personaddress,
    personphone,
    employer,
    bank_acct_type,
    transaction_date,
    account_type,
    product_type
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
        null                    employer_name,
        p.address
        || '|'
        || p.city
        || '|'
        || p.state
        || '|'
        || p.zip                personaddress,
        p.phone_day             personphone,
        'N'                     employer,
        case
            when at.bank_acct_type = 'C' then
                'Checking'
            else
                'Savings'
        end                     bank_acct_type,
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
                'HRA'
            when at.plan_type in ( 'HRAFSA', 'FSA', 'TRN', 'PKG', 'LPF',
                                   'DCA', 'IIR', 'UA1', 'TP2' ) then
                'FSA'
            when at.account_type in ( 'POP', 'ERISA_WRAP', 'FORM_5500', 'CMP' ) then
                'OPERATING'
            when at.account_type = 'HSA'   then
                'HSA'
            when at.account_type = 'COBRA' then
                'OPERATING'
            else
                'OPERATING'
        end                     product_type
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
        e.name                  employer_name,
        e.address
        || '|'
        || e.city
        || '|'
        || e.state
        || '|'
        || e.zip                empaddress,
        e.entrp_phones          as empphone,
        'Y'                     employer,
        case
            when at.bank_acct_type = 'C' then
                'Checking'
            else
                'Savings'
        end                     bank_acct_type,
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
                'HRA'
            when at.plan_type in ( 'HRAFSA', 'FSA', 'TRN', 'PKG', 'LPF',
                                   'DCA', 'IIR', 'UA1', 'TP2' ) then
                'FSA'
            when at.account_type in ( 'POP', 'ERISA_WRAP', 'FORM_5500', 'CMP' ) then
                'OPERATING'
            when at.account_type = 'HSA'   then
                'HSA'
            when at.account_type = 'COBRA' then
                'OPERATING'
            else
                'OPERATING'
        end                     product_type
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
        nvl(at.total_amount, 0) amount,
        at.bank_routing_num,
        at.bank_acct_num,
        e.name                  empname,
        null,
        e.name                  employer_name,
        e.address
        || '|'
        || e.city
        || '|'
        || e.state
        || '|'
        || e.zip                empaddress,
        e.entrp_phones          as empphone,
        'Y'                     employer,
        case
            when at.bank_acct_type = 'C' then
                'Checking'
            else
                'Savings'
        end                     bank_acct_type,
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
                'HRA'
            when at.plan_type in ( 'HRAFSA', 'FSA', 'TRN', 'PKG', 'LPF',
                                   'DCA', 'IIR', 'UA1', 'TP2' ) then
                'FSA'
            when at.account_type in ( 'POP', 'ERISA_WRAP', 'FORM_5500', 'CMP' ) then
                'OPERATING'
            when at.account_type = 'HSA'   then
                'HSA'
            when at.account_type = 'COBRA' then
                'OPERATING'
            else
                'OPERATING'
        end                     product_type
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

