create or replace force editionable view samqa.expense_category (
    lookup_code,
    meaning
) as
    select
        lookup_code,
        meaning
    from
        lookups
    where
        lookup_name = 'EXPENSE_CATEGORY';


-- sqlcl_snapshot {"hash":"c35e60c02e7379568b2fb4c9ae7d696471077edd","type":"VIEW","name":"EXPENSE_CATEGORY","schemaName":"SAMQA","sxml":""}