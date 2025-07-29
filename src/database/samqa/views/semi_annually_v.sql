create or replace force editionable view samqa.semi_annually_v (
    rn,
    q_end
) as
    select
        rownum rn,
        add_months(
            trunc(sysdate, 'yyyy'),
            rownum * 6
        )      q_end
    from
        all_objects
    where
        rownum <= 2;


-- sqlcl_snapshot {"hash":"8518a22e0e61d282dc341de767a8de4ddb1e0b10","type":"VIEW","name":"SEMI_ANNUALLY_V","schemaName":"SAMQA","sxml":""}