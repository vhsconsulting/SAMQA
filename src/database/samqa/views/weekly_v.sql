create or replace force editionable view samqa.weekly_v (
    period_date
) as
    with data as (
        select
            level - 1 k
        from
            dual
        connect by
            level <= 52
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


-- sqlcl_snapshot {"hash":"2233635dfc2183f20c2f6db45c0460d83a40de49","type":"VIEW","name":"WEEKLY_V","schemaName":"SAMQA","sxml":""}