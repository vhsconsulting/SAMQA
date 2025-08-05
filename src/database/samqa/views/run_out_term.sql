create or replace force editionable view samqa.run_out_term (
    lookup_code,
    meaning
) as
    select
        lookup_code,
        meaning
    from
        lookups
    where
        lookup_name = 'RUN_OUT_TERM';


-- sqlcl_snapshot {"hash":"68cd9a7bfd9e73b53e2ff6b1b28238afd9cfb5b5","type":"VIEW","name":"RUN_OUT_TERM","schemaName":"SAMQA","sxml":""}