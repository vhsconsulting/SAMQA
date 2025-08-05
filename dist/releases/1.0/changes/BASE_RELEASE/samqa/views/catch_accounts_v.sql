-- liquibase formatted sql
-- changeset SAMQA:1754374169691 stripComments:false logicalFilePath:BASE_RELEASE\samqa\views\catch_accounts_v.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/views/catch_accounts_v.sql:null:09e9e77b8629e50cb7ab8d3727c8441dbf5335cf:create

create or replace force editionable view samqa.catch_accounts_v (
    pers_id,
    birth_date,
    patient_age
) as
    select
        pers_id,
        birth_date,
        trunc(months_between(sysdate, birth_date) / 12)
        || ' years old and '
        || mod(
            months_between(sysdate + 15, birth_date),
            12
        )
        || ' months old ' patient_age
    from
        person
    where
            trunc(months_between(sysdate, birth_date) / 12) = 54
        and mod(
            months_between(sysdate + 15, birth_date),
            12
        ) = 11;

