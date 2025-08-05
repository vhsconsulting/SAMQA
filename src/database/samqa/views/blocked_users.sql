create or replace force editionable view samqa.blocked_users (
    user_name,
    find_key
) as
    select
        user_name,
        find_key
    from
        online_users
    where
        blocked = 'Y';


-- sqlcl_snapshot {"hash":"19fddb85ee0e8a0a6f5ec256c96f41cf8df4e1c5","type":"VIEW","name":"BLOCKED_USERS","schemaName":"SAMQA","sxml":""}