create or replace force editionable view samqa.spiff_details_v (
    name,
    acc_num,
    tax_id,
    start_date,
    no_of_products
) as
    select
        name,
        p.acc_num,
        x.tax_id,
        p.start_date,
        x.cnt no_of_products
    from
        portfolio_accounts p,
        (
            select
                b.name,
                count(a.acc_num) cnt,
                replace(
                    replace(a.tax_id, ' '),
                    '-'
                )                tax_id
            from
                portfolio_accounts a,
                salesrep           b
            where
                trunc(a.start_date, 'MM') between add_months(
                    trunc(sysdate, 'MM'),
                    -3
                ) and sysdate
                and a.salesrep_id = b.salesrep_id
            group by
                replace(
                    replace(a.tax_id, ' '),
                    '-'
                ),
                b.name
            having
                count(a.acc_num) > 1
            order by
                replace(
                    replace(a.tax_id, ' '),
                    '-'
                )
        )                  x
    where
        replace(
            replace(p.tax_id, ' '),
            '-'
        ) = replace(
            replace(x.tax_id, ' '),
            '-'
        )
    order by
        1;


-- sqlcl_snapshot {"hash":"766fd47b469f472991ca96a407b708d90e1bd7a4","type":"VIEW","name":"SPIFF_DETAILS_V","schemaName":"SAMQA","sxml":""}