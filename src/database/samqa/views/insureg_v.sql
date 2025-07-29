create or replace force editionable view samqa.insureg_v (
    pers_id,
    reg_date,
    insur_id,
    iname,
    plan_type_m,
    plan_type
) as
    (
        select
            a.pers_id,
            a.reg_date,
            i.insur_id,
            e.name                                as iname,
            pc_lookups.get_plan_type(i.plan_type) plan_type_m,
            i.plan_type
        from
            account    a,
            insure     i,
            enterprise e
        where
                a.pers_id = i.pers_id
            and i.insur_id = e.entrp_id
            and a.account_status <> 5
    );


-- sqlcl_snapshot {"hash":"741eb14d3a9cb89edfcb2af8ff8916169f7b1b39","type":"VIEW","name":"INSUREG_V","schemaName":"SAMQA","sxml":""}