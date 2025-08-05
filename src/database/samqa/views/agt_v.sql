create or replace force editionable view samqa.agt_v (
    low,
    age,
    male,
    female,
    na,
    total
) as
    (
        select
            nvl(low, -1) as low,
            age,
            male,
            female,
            na,
            total
        from
            agc_v
        union all
        select
            999,
            'Total',
            sum(male),
            sum(female),
            sum(na),
            sum(total)
        from
            agc_v
    );


-- sqlcl_snapshot {"hash":"96d37136195e44436dce894fd1345fdc50cc0870","type":"VIEW","name":"AGT_V","schemaName":"SAMQA","sxml":""}