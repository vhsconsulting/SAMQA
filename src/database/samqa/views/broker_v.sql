create or replace force editionable view samqa.broker_v (
    broker_id,
    broker_lic,
    name,
    address,
    city,
    state,
    zip,
    agency_name,
    phone_day,
    email,
    tax_id
) as
    select
        a.broker_id,
        a.broker_lic,
        b.first_name
        || ' '
        || b.last_name name,
        b.address,
        b.city,
        b.state,
        b.zip,
        a.agency_name,
        b.phone_day,
        b.email,
        b.ssn
    from
        broker a,
        person b
    where
        a.broker_id = b.pers_id;


-- sqlcl_snapshot {"hash":"7c16dfd11b3b4261e530c498828c0b940cdf3c38","type":"VIEW","name":"BROKER_V","schemaName":"SAMQA","sxml":""}