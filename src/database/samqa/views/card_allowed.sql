create or replace force editionable view samqa.card_allowed (
    lookup_code,
    meaning
) as
    select
        lookup_code,
        meaning
    from
        lookups
    where
        lookup_name = 'CARD_ALLOWED';


-- sqlcl_snapshot {"hash":"5a1ef4ff839c19a551a459ec83de58d58c59ed0a","type":"VIEW","name":"CARD_ALLOWED","schemaName":"SAMQA","sxml":""}