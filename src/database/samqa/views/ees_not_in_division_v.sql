create or replace force editionable view samqa.ees_not_in_division_v (
    last_name,
    first_name,
    middle_name,
    name,
    pers_id,
    entrp_id,
    acc_num,
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
        a.pers_id,
        a.entrp_id,
        b.acc_num,
        b.acc_id
    from
        person  a,
        account b
    where
        a.division_code is null
        and a.pers_id = b.pers_id
        and exists (
            select
                *
            from
                employer_divisions
            where
                entrp_id = a.entrp_id
        );


-- sqlcl_snapshot {"hash":"fa24d84d0d27e755fddc9efee8cedaa6ed297521","type":"VIEW","name":"EES_NOT_IN_DIVISION_V","schemaName":"SAMQA","sxml":""}