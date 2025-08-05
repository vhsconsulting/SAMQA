create or replace force editionable view samqa.broker_accounts_v (
    broker_id,
    start_date,
    end_date,
    broker_lic,
    broker_salesrep_id,
    broker_salesrep,
    broker_name,
    city,
    state,
    zip,
    email
) as
    select distinct
        b.broker_id,
        b.start_date,
        b.end_date,
        b.broker_lic,
        b.salesrep_id broker_salesrep_id,
        s.name        broker_salesrep,
        replace(
            trim(pb.first_name
                 || ' '
                 || pb.last_name),
            '  ',
            ' '
        )             broker_name,
        pb.city,
        pb.state,
        pb.zip,
        pb.email
    from
        broker   b,
        account  a,
        person   pb,
        salesrep s
    where
            b.broker_id = a.broker_id
        and a.broker_id = pb.pers_id (+)
        and b.salesrep_id = s.salesrep_id (+);


-- sqlcl_snapshot {"hash":"29c40f92e57a7c522e0738d73f16b2adab82138b","type":"VIEW","name":"BROKER_ACCOUNTS_V","schemaName":"SAMQA","sxml":""}