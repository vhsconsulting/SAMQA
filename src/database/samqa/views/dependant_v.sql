create or replace force editionable view samqa.dependant_v (
    name,
    first_name,
    middle_name,
    last_name,
    pers_main,
    pers_id,
    ssn,
    relat_name,
    relat_code,
    gender,
    birth_date,
    card_exist,
    subscriber_ssn
) as
    select
        decode(a.title, null, '', ' .')
        || a.first_name
        || ' '
        || a.middle_name
        || ' '
        || a.last_name                               name,
        a.first_name,
        a.middle_name,
        a.last_name,
        a.pers_main,
        a.pers_id,
        a.ssn,
        (
            select
                relat_name
            from
                relative
            where
                relat_code = a.relat_code
        )                                            relat_name,
        a.relat_code,
        decode(a.gender, 'M', 'Male', 'F', 'Female') gender,
        to_char(a.birth_date, 'MM/DD/YYYY')          birth_date,
        (
            select
                count(*)
            from
                card_debit
            where
                card_id = a.pers_id
        )                                            card_exist,
        b.ssn                                        subscriber_ssn
    from
        person a,
        person b
    where
            a.pers_main = b.pers_id
        and a.pers_main is not null
        and a.person_type <> 'SUBSCRIBER'
        and a.pers_end_date is null;


-- sqlcl_snapshot {"hash":"1f787a939e2266b71b48074eee6b3da9ea93b07f","type":"VIEW","name":"DEPENDANT_V","schemaName":"SAMQA","sxml":""}