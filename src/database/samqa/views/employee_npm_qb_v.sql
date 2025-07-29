create or replace force editionable view samqa.employee_npm_qb_v (
    rn,
    entrp_id,
    use_family,
    waive_covr,
    send_general_right_letter,
    address,
    phone_day,
    email,
    division_code,
    division_name,
    name,
    first_name,
    last_name,
    pers_id,
    hire_date,
    er_acc_num,
    ee_acc_num,
    er_acc_id,
    account_status,
    birth_date,
    employer_name,
    masked_ssn,
    ssn,
    persontype,
    person_type
) as
    (
        select
            mod(rownum, 2)                                             rn,
            a.entrp_id,
            a.use_family,
            a.waive_covr,
            a.send_general_right_letter,
            a.address
            || ' '
            || nvl(a.city, '')
            || ' '
            || nvl(a.state, '')
            || ' '
            || nvl(a.zip, '')                                          address,
            nvl(a.phone_day, a.phone_even)                             phone_day,
            a.email,
            a.division_code,
            (
                select
                    division_name
                from
                    employer_divisions
                where
                        division_code = a.division_code
                    and rownum < 2
            )                                                          division_name,
            a.first_name
            || ' '
            || a.last_name                                             name,
            a.first_name,
            a.last_name,
            a.pers_id,
            a.hire_date,
            b.acc_num                                                  er_acc_num,
            nvl((
                select
                    acc_num
                from
                    account
                where
                    pers_id = a.pers_id
            ), b.acc_num)                                              ee_acc_num,
            b.acc_id                                                   er_acc_id,
            pc_lookups.get_meaning(b.account_status, 'ACCOUNT_STATUS') account_status,
            to_char(a.birth_date, 'MM/DD/YYYY')                        birth_date,
            pc_entrp.get_entrp_name(a.entrp_id)                        employer_name,
            a.masked_ssn,
            a.ssn,
            a.person_type                                              persontype,
            pc_lookups.get_meaning(a.person_type, 'MEMBER_TYPE')       person_type
        from
            person  a,
            account b
        where
                a.entrp_id = b.entrp_id (+)
            and a.person_type in ( 'QB', 'NPM' )
    );


-- sqlcl_snapshot {"hash":"c0dea31de0692320e8626a4a3591b745812adef4","type":"VIEW","name":"EMPLOYEE_NPM_QB_V","schemaName":"SAMQA","sxml":""}