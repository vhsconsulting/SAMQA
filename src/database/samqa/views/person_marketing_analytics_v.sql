create or replace force editionable view samqa.person_marketing_analytics_v (
    pers_id,
    first_name,
    last_name,
    address,
    city,
    state,
    zip,
    email,
    plan_type
) as
    select distinct
        c.pers_id,
        '"'
        || b.first_name
        || '"' first_name,
        '"'
        || b.last_name
        || '"' last_name,
        '"'
        || b.address
        || '"' address,
        '"'
        || b.city
        || '"' city,
        '"'
        || b.state
        || '"' state,
        '"'
        || b.zip
        || '"' zip,
        ou.email,
        bp.plan_type
    from
        person                    b,
        account                   c,
        ben_plan_enrollment_setup bp,
        online_users              ou
    where
            b.pers_id = c.pers_id
        and c.acc_id = bp.acc_id
        and b.ssn = format_ssn(ou.tax_id)
        and c.account_type in ( 'HRA', 'FSA', 'CMP' )
    union
    select distinct
        c.pers_id,
        '"'
        || b.first_name
        || '"' first_name,
        '"'
        || b.last_name
        || '"' last_name,
        '"'
        || b.address
        || '"' address,
        '"'
        || b.city
        || '"' city,
        '"'
        || b.state
        || '"' state,
        '"'
        || b.zip
        || '"' zip,
        ou.email,
        c.account_type
    from
        person       b,
        account      c,
        online_users ou
    where
            b.pers_id = c.pers_id
        and b.ssn = format_ssn(ou.tax_id)
        and c.account_type not in ( 'HRA', 'FSA', 'CMP' );


-- sqlcl_snapshot {"hash":"558453cf459f02cfca7aae5e0a3ba96994defa34","type":"VIEW","name":"PERSON_MARKETING_ANALYTICS_V","schemaName":"SAMQA","sxml":""}