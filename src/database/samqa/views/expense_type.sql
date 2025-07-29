create or replace force editionable view samqa.expense_type (
    lookup_name,
    expense_code,
    expense_name,
    expense_nshort
) as
    select
        lookup_name,
        lookup_code expense_code,
        description expense_name,
        meaning     expense_nshort
    from
        lookups
    where
        lookup_name = 'EXPENSE_TYPE';


-- sqlcl_snapshot {"hash":"137bab8551a85d633b63eca24613aa4fcc502655","type":"VIEW","name":"EXPENSE_TYPE","schemaName":"SAMQA","sxml":""}