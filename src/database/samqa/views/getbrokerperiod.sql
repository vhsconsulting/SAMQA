create or replace force editionable view samqa.getbrokerperiod (
    idx,
    period,
    meaning
) as
    select
        rn       idx,
        q_start
        || '#'
        || q_end period,
        decode(rn, 1, 'First ', 2, 'Second',
               3, 'Third', 4, 'Fourth')
        || ' Quarter (Q'
        || rn
        || ' '
        || yer
        || ')'   meaning
    from
        (
            select
                rownum rn,
                add_months(
                    trunc((trunc(sysdate, 'yyyy')),
                          'YYYY'),
                    (rownum - 1) * 3
                )      q_start,
                add_months(
                    trunc((trunc(sysdate, 'yyyy')),
                          'YYYY'),
                    rownum * 3
                ) - 1  q_end,
                to_char(
                    trunc(sysdate, 'yyyy'),
                    'YYYY'
                )      yer
            from
                all_objects
            where
                rownum <= 4
            union
            select
                rownum          rn,
                add_months(
                    trunc((trunc(sysdate, 'yyyy') - 1),
                          'YYYY'),
                    (rownum - 1) * 3
                )               q_start,
                add_months(
                    trunc((trunc(sysdate, 'yyyy') - 1),
                          'YYYY'),
                    rownum * 3
                ) - 1           q_end,
                to_char(trunc(sysdate, 'yyyy') - 1,
                        'YYYY') yer
            from
                all_objects
            where
                rownum <= 4
        )
    where
        q_end < trunc(sysdate, 'MM');


-- sqlcl_snapshot {"hash":"2019a702b59b15191ace1430b5d045cce1074af0","type":"VIEW","name":"GETBROKERPERIOD","schemaName":"SAMQA","sxml":""}