create or replace force editionable view samqa.broker_commission_v (
    broker_id,
    broker_lic,
    broker_rate,
    name,
    amount,
    pay_date,
    entrp_name
) as
    select
        b.broker_id,
        b.broker_lic,
        b.broker_rate,
        c.first_name
        || ' '
        || c.middle_name
        || ' '
        || c.last_name name,
        b.amount,
        b.pay_date,
        (
            select
                name
            from
                enterprise
            where
                entrp_id = c.entrp_id
        )              entrp_name
    from
        broker_commission_register b,
        person                     c
    where
        b.pers_id = c.pers_id;


-- sqlcl_snapshot {"hash":"e1f266265bb89ca478291cc467b12b4a46cb84ef","type":"VIEW","name":"BROKER_COMMISSION_V","schemaName":"SAMQA","sxml":""}