-- liquibase formatted sql
-- changeset SAMQA:1754374171825 stripComments:false logicalFilePath:BASE_RELEASE\samqa\views\ees_in_division_v.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/views/ees_in_division_v.sql:null:dfa3a3b4609bcc10835f2c74e799ad90d065dfed:create

create or replace force editionable view samqa.ees_in_division_v (
    last_name,
    first_name,
    middle_name,
    name,
    acc_num,
    division_code,
    division_name,
    description,
    pers_id,
    entrp_id,
    acc_id
) as
    select
        a.last_name,
        a.first_name,
        a.middle_name,
        a.last_name
        || ' '
        || a.middle_name
        || ' '
        || a.first_name name,
        c.acc_num,
        b.division_code,
        b.division_name,
        b.description,
        a.pers_id,
        b.entrp_id,
        c.acc_id
    from
        person             a,
        employer_divisions b,
        account            c
    where
            a.entrp_id = b.entrp_id
        and a.pers_id = c.pers_id
        and a.division_code = b.division_code;

