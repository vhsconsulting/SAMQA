create or replace force editionable view samqa.broker_emp_v (
    broker_id,
    broker_lic,
    name,
    acc_num,
    start_date,
    no_of_employees
) as
    select
        a.broker_id,
        a.broker_lic,
        b.name,
        c.acc_num,
        c.start_date,
        (
            select
                count(distinct d.pers_id)
            from
                person             d,
                account            e,
                broker_assignments ba
            where
                    d.pers_id = e.pers_id
                and d.entrp_id = b.entrp_id
                and ba.broker_id = e.broker_id
                and e.account_status in ( 1, 2 )
                and d.pers_id = ba.pers_id
                and ba.effective_end_date is null
        ) no_of_employees
    from
        broker     a,
        enterprise b,
        account    c
    where
            a.broker_id = c.broker_id
        and c.entrp_id = b.entrp_id
        and c.pers_id is null
    order by
        b.name;


-- sqlcl_snapshot {"hash":"a70c1ecc8dbd226acae1626003518ec42c559309","type":"VIEW","name":"BROKER_EMP_V","schemaName":"SAMQA","sxml":""}