-- liquibase formatted sql
-- changeset SAMQA:1754374170984 stripComments:false logicalFilePath:BASE_RELEASE\samqa\views\contributor_v.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/views/contributor_v.sql:null:518fbe10408b6ecc1f40e0799008b5698e410393:create

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

