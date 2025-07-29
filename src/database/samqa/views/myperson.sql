create or replace force editionable view samqa.myperson (
    pers_id,
    acc_id,
    acc_num,
    reg_date,
    start_date,
    end_date,
    gender,
    birth_date,
    low,
    age,
    title,
    first_name,
    middle_name,
    last_name,
    ssn,
    address,
    city,
    state,
    zip,
    county,
    profession,
    pers_main,
    relat_name,
    group_n,
    broker_lic,
    fee_maint,
    fee_setup,
    plan_name,
    insur_name,
    deductible,
    allow_contr,
    catch_up,
    sum_fees,
    start_ins,
    end_ins,
    daytime_phone,
    evening_phone,
    s_email,
    contact_me,
    person_note,
    subs_number,
    out_of_pocket,
    term,
    account_status,
    suspended_date,
    complete_flag,
    broker_effective_date
) as
    (
        select
            p.pers_id,
            a.acc_id,
            a.acc_num,
            a.reg_date,
            a.start_date,
            a.end_date,
            p.gender,
            p.birth_date,
            ag.low,
            ag.age,
            rtrim(p.title, '.')                        as title,
            p.first_name,
            p.middle_name,
            p.last_name,
            p.ssn,
            p.address,
            p.city,
            p.state,
            p.zip,
            p.county,
            p.profession,
            p.pers_main,
            r.relat_name,
            ae.acc_num                                 as group_n,
            nvl(b.broker_lic, 'SK' || b.broker_id)     as broker_lic,
            a.fee_maint                                as fee_maint,
            a.fee_setup,
            substr(l.plan_name, 1, 20)                 as plan_name,
            e.name                                     as insur_name, -- add second param, dates to 4 fields below, for 2006 open in 2005
            i.deductible                               as deductible,
            pc_person.allow_deductible(p.pers_id,
                                       greatest(a.start_date, sysdate)) as allow_contr,
            pc_person.allow_deductible55(p.pers_id,
                                         greatest(a.start_date, sysdate)) as catch_up,
            pc_fin.allow_fee(a.acc_id,
                             greatest(a.start_date, sysdate))    as sum_fees,
            i.start_date                               as start_ins,
            i.end_date                                 as end_ins,
            substr(phone_day, 1, 30)                   as daytime_phone,
            substr(phone_even, 1, 30)                  as evening_phone,
            substr(email, 1, 50)                       as s_email,
            rtrim(mt.mail_name, 'number')              as contact_me,
            substr(
                translate(p.note,
                          chr(10)
                          || chr(13),
                          '  '),
                1,
                100
            )                                          as person_note,
            i.policy_num                               as subs_number,
            i.op_max                                   as out_of_pocket,
            null                                       as term,
            a.account_status,
            a.suspended_date,
            a.complete_flag,
            (
                select
                    max(effective_date)
                from
                    broker_assignments
                where
                        broker_id = a.broker_id
                    and pers_id = p.pers_id
            )                                          broker_effective_date
        from
            person     p,
            account    a,
            account    ae,
            relative   r,
            insure     i,
            broker     b,
            plans      l,
            enterprise e,
            agender    ag,
            mail_type  mt
        where
                a.pers_id = p.pers_id
            and p.pers_id > 0                                   -- omit service person
            and p.entrp_id = ae.entrp_id (+)  -- Person's Enterprise may has account
            and a.broker_id = b.broker_id
            and p.relat_code = r.relat_code (+)
            and p.pers_id = i.pers_id (+)
            and a.plan_code = l.plan_code
            and i.insur_id = e.entrp_id (+)
            and nvl(
                trunc((a.reg_date - p.birth_date) / 365.25),
                -1
            ) between low and hi
            and p.mailmet = mt.mail_code (+)
        union
        select
            p.pers_id,
            (
                select
                    acc_id
                from
                    account
                where
                    pers_id = p.pers_main
            ),
            (
                select
                    acc_num
                from
                    account
                where
                    pers_id = p.pers_main
            ),
            null,
            null,
            null,
            p.gender,
            p.birth_date,
            ag.low,
            ag.age,
            rtrim(p.title, '.')                              as title,
            p.first_name,
            p.middle_name,
            p.last_name,
            p.ssn,
            p.address,
            p.city,
            p.state,
            p.zip,
            p.county,
            p.profession,
            p.pers_main,
            r.relat_name,
            null                                             as group_n,
            null                                             as broker_lic,
            null                                             as fee_maint,
            null,
            null                                             as plan_name,
            e.name                                           as insur_name, -- add second param, dates to 4 fields below, for 2006 open in 2005
            i.deductible                                     as deductible,
            pc_person.allow_deductible(p.pers_id, sysdate)   as allow_contr,
            pc_person.allow_deductible55(p.pers_id, sysdate) as catch_up,
            null                                             as sum_fees,
            i.start_date                                     as start_ins,
            i.end_date                                       as end_ins,
            substr(phone_day, 1, 30)                         as daytime_phone,
            substr(phone_even, 1, 30)                        as evening_phone,
            substr(email, 1, 50)                             as s_email,
            rtrim(mt.mail_name, 'number')                    as contact_me,
            substr(
                translate(p.note,
                          chr(10)
                          || chr(13),
                          '  '),
                1,
                100
            )                                                as person_note,
            i.policy_num                                     as subs_number,
            i.op_max                                         as out_of_pocket,
            null                                             as term,
            null,
            null,
            null,
            null                                             broker_effective_date
        from
            person     p,
            account    ae,
            relative   r,
            insure     i,
            enterprise e,
            agender    ag,
            mail_type  mt
        where
            p.pers_main is not null                                -- omit service person
            and not exists (
                select
                    *
                from
                    account
                where
                    pers_id = p.pers_id
            )
            and p.entrp_id = ae.entrp_id (+)  -- Person's Enterprise may has account
            and p.relat_code = r.relat_code (+)
            and p.pers_id = i.pers_id (+)
            and i.insur_id = e.entrp_id (+)
            and nvl(
                trunc((sysdate - p.birth_date) / 365.25),
                -1
            ) between low and hi
            and p.mailmet = mt.mail_code (+)
    );


-- sqlcl_snapshot {"hash":"a3217f370003e2f6204894ecd16f0e35636f95ad","type":"VIEW","name":"MYPERSON","schemaName":"SAMQA","sxml":""}