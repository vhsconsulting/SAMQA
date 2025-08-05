create or replace force editionable view samqa.broker_ind_v (
    broker_id,
    broker_lic,
    name,
    acc_num,
    start_date
) as
    select
        a.broker_id,
        a.broker_lic,
        b.first_name
        || ' '
        || b.last_name name,
        c.acc_num,
        c.start_date
    from
        broker             a,
        person             b,
        account            c,
        broker_assignments ba
    where
            a.broker_id = c.broker_id
        and c.pers_id = b.pers_id
        and c.entrp_id is null
        and b.pers_id = ba.pers_id
        and ba.broker_id = a.broker_id
        and ba.effective_end_date is null;


-- sqlcl_snapshot {"hash":"bedcb0236125fba7dc0fb25642b916c2bb0a4f31","type":"VIEW","name":"BROKER_IND_V","schemaName":"SAMQA","sxml":""}