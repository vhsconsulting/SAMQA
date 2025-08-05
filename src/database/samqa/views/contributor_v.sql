create or replace force editionable view samqa.contributor_v (
    contributor,
    pers_id,
    name
) as
    select
        p.entrp_id contributor,
        p.pers_id  pers_id, /* 'Employer' */
        name
    from
        person     p,
        enterprise e
    where
        p.entrp_id = e.entrp_id;


-- sqlcl_snapshot {"hash":"518fbe10408b6ecc1f40e0799008b5698e410393","type":"VIEW","name":"CONTRIBUTOR_V","schemaName":"SAMQA","sxml":""}