create or replace force editionable view samqa.biweekly_v (
    period_date
) as
    with data as (
        select
            2 * level k
        from
            dual
        connect by
            level <= 26
    )
    select
        add_weeks(
            trunc(sysdate, 'yyyy'),
            k
        ) period_date
    from
        data
    order by
        1;


-- sqlcl_snapshot {"hash":"2f56c8866e4142d986a58a086f3b52c07e7dace2","type":"VIEW","name":"BIWEEKLY_V","schemaName":"SAMQA","sxml":""}