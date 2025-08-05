create or replace force editionable view samqa.crm_users (
    "user_name",
    "id",
    full_name,
    "status"
) as
    select
        "user_name",
        "id",
        "first_name"
        || ' '
        || "last_name" as full_name,
        "status"
    from
        "users"@sugarprod;


-- sqlcl_snapshot {"hash":"1d572f2696ccfae5315a34459bfd1a59006f0438","type":"VIEW","name":"CRM_USERS","schemaName":"SAMQA","sxml":""}