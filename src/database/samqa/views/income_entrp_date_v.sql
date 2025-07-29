create or replace force editionable view samqa.income_entrp_date_v (
    contributor,
    fee_date,
    list_bill,
    check_amount,
    acc_id,
    amount,
    amount_add
) as
    select
        contributor,
        fee_date,
        list_bill,
        contributor_amount,
        acc_id,
        amount,
        amount_add
    from
        (
            select
                contributor               contributor,
                fee_date                  fee_date,
                nvl(list_bill, cc_number) list_bill,
                contributor_amount,
                count(acc_id)             acc_id,
                sum(nvl(amount, 0))       amount,
                sum(nvl(amount_add, 0))   amount_add
            from
                income
            where
                contributor is not null
            group by
                contributor,
                fee_date,
                nvl(list_bill, cc_number),
                contributor_amount
        );


-- sqlcl_snapshot {"hash":"4065d46dfef0e4b7b1a88655f62bbe8f42df6b1d","type":"VIEW","name":"INCOME_ENTRP_DATE_V","schemaName":"SAMQA","sxml":""}