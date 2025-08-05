create or replace force editionable view samqa.income_statement_v (
    fee_date,
    fee_code,
    fee_name,
    amount,
    amount_add,
    er_fee_amount,
    ee_fee_amount,
    total_received,
    acc_id,
    contributor
) as
    select
        fee_date,
        case
            when fee_code in ( 7, 10 ) then
                'PY'
            when fee_code = 8 then
                null
            else
                'CY'
        end                                                                                 fee_code,
        case
            when fee_code in ( 9, 15, 16 ) then
                'Refund'
            when nvl(er_fee_amount, 0) + nvl(ee_fee_amount, 0) > 0 then
                pc_lookups.get_fee_reason(fee_code)
                || ' and fees '
            else
                pc_lookups.get_fee_reason(fee_code)
        end                                                                                 fee_name,
        amount,
        amount_add,
        er_fee_amount,
        ee_fee_amount,
        nvl(amount, 0) + nvl(amount_add, 0) + nvl(er_fee_amount, 0) + nvl(ee_fee_amount, 0) total_received,
        acc_id,
        contributor
    from
        income
    where
        nvl(fee_code, '-1') not in ( 11, 12 );


-- sqlcl_snapshot {"hash":"f075901eaa732f5451d840a97b77ee3fb2f2f928","type":"VIEW","name":"INCOME_STATEMENT_V","schemaName":"SAMQA","sxml":""}