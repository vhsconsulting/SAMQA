create or replace force editionable view samqa.audit_enrollments_v (
    acc_num,
    entered_first_name,
    entered_last_name,
    entered_address,
    entered_city,
    entered_state,
    entered_zip,
    entered_birthdate,
    entered_ssn,
    entered_dlp,
    corrected_first_name,
    corrected_last_name,
    corrected_address,
    corrected_city,
    corrected_state,
    corrected_zip,
    corrected_birthdate,
    corrected_ssn,
    corrected_dlp
) as
    select
        entered.acc_num,
        entered.first_name,
        entered.last_name,
        entered.address,
        entered.city,
        entered.state,
        entered.zip,
        entered.birth_date,
        entered.ssn,
        entered.idnumber   dl_passport,
        corrected.first_name,
        corrected.last_name,
        corrected.address,
        corrected.city,
        corrected.state,
        corrected.zip,
        corrected.birth_date,
        corrected.ssn,
        corrected.idnumber dl_passport
    from
        (
            select
                b.acc_num,
                a.first_name,
                a.last_name,
                a.address,
                a.city,
                a.state,
                a.zip,
                a.birth_date,
                format_ssn(a.ssn)                 ssn,
                nvl(a.driver_license, a.passport) idnumber
            from
                mass_enrollments a,
                account          b,
                person           c
            where
                    a.mass_enrollment_id = c.mass_enrollment_id
                and c.pers_id = b.pers_id
                and a.created_by in ( 2541, 2542 )
                and b.creation_date > sysdate - 1
        ) entered,
        (
            select
                b.acc_num,
                a.first_name,
                a.last_name,
                a.address,
                a.city,
                a.state,
                a.zip,
                to_char(a.birth_date, 'MMDDYYYY') birth_date,
                a.ssn,
                nvl(a.drivlic, a.passport)        idnumber
            from
                person  a,
                account b
            where
                    a.pers_id = b.pers_id
                and b.created_by in ( 2541, 2542 )
                and b.creation_date > sysdate - 1
        ) corrected
    where
            entered.acc_num = corrected.acc_num
        and ( entered.first_name <> corrected.first_name
              or entered.last_name <> corrected.last_name
              or entered.address <> corrected.address
              or entered.city <> corrected.city
              or entered.state <> corrected.state
              or entered.zip <> corrected.zip
              or entered.birth_date <> corrected.birth_date
              or entered.ssn <> corrected.ssn );


-- sqlcl_snapshot {"hash":"92f4711a414bfa7d4975e8c828e686ad3e16c498","type":"VIEW","name":"AUDIT_ENROLLMENTS_V","schemaName":"SAMQA","sxml":""}