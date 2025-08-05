create or replace force editionable view samqa.brokreg_v (
    pers_id,
    reg_date,
    broker_id,
    bname
) as
    (
        select
            pers_id,
            reg_date,
            broker_id,
            pc_person.pers_fld(broker_id, 'full_name') as bname
        from
            account
    );


-- sqlcl_snapshot {"hash":"535c12d518262d9f9a8ea4dc0b6806f48886cbca","type":"VIEW","name":"BROKREG_V","schemaName":"SAMQA","sxml":""}