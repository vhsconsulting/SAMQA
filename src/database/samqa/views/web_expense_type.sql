create or replace force editionable view samqa.web_expense_type (
    lookup_code,
    meaning
) as
    select
        lookup_code,
        meaning
    from
        lookups
    where
        lookup_name = 'WEB_EXPENSE_TYPE';


-- sqlcl_snapshot {"hash":"fc9fd4d63a1e6cb1b7c94d67d288c88e85de2afb","type":"VIEW","name":"WEB_EXPENSE_TYPE","schemaName":"SAMQA","sxml":""}