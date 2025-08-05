create or replace force editionable view samqa.myhealthplan (
    id,
    name,
    entrp_id
) as
    (
        select
            entrp_id as id,
            name,
            entrp_id
        from
            enterprise
        where
            en_code = 3
    );


-- sqlcl_snapshot {"hash":"f58d7e078b01937c7a058d8d50befe2c5ce883ac","type":"VIEW","name":"MYHEALTHPLAN","schemaName":"SAMQA","sxml":""}