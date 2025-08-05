create or replace force editionable view samqa.broker_marketing_analytics_v (
    broker_id,
    first_name,
    last_name,
    agency_name,
    address,
    city,
    state,
    zip,
    email,
    registered,
    account_type
) as
    select distinct
        a.broker_id,
        '"'
        || b.first_name
        || '"' first_name,
        '"'
        || b.last_name
        || '"' last_name,
        '"'
        || a.agency_name
        || '"' agency_name,
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
        b.email,
        (
            select
                count(*)
            from
                online_users
            where
                    user_type = 'B'
                and find_key = nvl(a.broker_lic, 'SK' || a.broker_id)
        )      registered,
        case
            when c.account_type in ( 'HRA', 'FSA', 'CMP' ) then
                bp.plan_type
            else
                c.account_type
        end    account_type
    from
        broker                    a,
        person                    b,
        account                   c,
        ben_plan_enrollment_setup bp
    where
            a.broker_id = b.pers_id
        and a.broker_id = c.broker_id (+)
        and c.acc_id = bp.acc_id;


-- sqlcl_snapshot {"hash":"e0258c660ac772ff3a0cca478c836f5291a376a6","type":"VIEW","name":"BROKER_MARKETING_ANALYTICS_V","schemaName":"SAMQA","sxml":""}