create or replace force editionable view samqa.cards_v (
    lookup_name,
    stat,
    nstat,
    note
) as
    select
        lookup_name,
        lookup_code stat,
        meaning     nstat,
        description note
    from
        lookups
    where
        lookup_name = 'DEBIT_CARD_STATUS';


-- sqlcl_snapshot {"hash":"a01e73650e95040041b954b11016b979c8e826b6","type":"VIEW","name":"CARDS_V","schemaName":"SAMQA","sxml":""}