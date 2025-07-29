create or replace force editionable view samqa.quarterly_v (
    rn,
    period_date
) as
    select
        rownum rn,
        add_months(
            trunc(sysdate, 'yyyy'),
            rownum * 3
        )      period_date
    from
        all_objects
    where
        rownum <= 4;


-- sqlcl_snapshot {"hash":"11102090efc584cbe59db2d8111138869590461b","type":"VIEW","name":"QUARTERLY_V","schemaName":"SAMQA","sxml":""}