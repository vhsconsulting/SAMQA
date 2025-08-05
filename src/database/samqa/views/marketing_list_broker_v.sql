create or replace force editionable view samqa.marketing_list_broker_v (
    first_name,
    last_name,
    agency_name,
    address,
    city,
    state,
    zip,
    registered,
    acc_list
) as
    select
        b.first_name,
        b.last_name,
        a.agency_name,
        b.address,
        b.city,
        b.state,
        b.zip,
        (
            select
                count(*)
            from
                online_users
            where
                    user_type = 'B'
                and find_key = nvl(a.broker_lic, 'SK' || a.broker_id)
        ) registered,
        (
            select --WM_CONCAT(DISTINCT AC.ACCOUNT_TYPE)
                listagg(ac.account_type, ',') within group(
                order by
                    ac.account_type
                )
            from
                account ac
            where
                    ac.broker_id = a.broker_id
                and ac.entrp_id is not null
        ) acc_list
    from
        broker a,
        person b
    where
        a.broker_id = b.pers_id;


-- sqlcl_snapshot {"hash":"1871409d928f799fdd31e0fab9b08786f7408d27","type":"VIEW","name":"MARKETING_LIST_BROKER_V","schemaName":"SAMQA","sxml":""}