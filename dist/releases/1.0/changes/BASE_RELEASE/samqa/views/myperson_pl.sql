-- liquibase formatted sql
-- changeset SAMQA:1754374177453 stripComments:false logicalFilePath:BASE_RELEASE\samqa\views\myperson_pl.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/views/myperson_pl.sql:null:023f77733ebf287cc834fc955735ea0ca26219a3:create

create or replace force editionable view samqa.myperson_pl (
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
    broker_effective_date,
    employer,
    emp_contact,
    emp_email,
    emp_phone
) as
    select
        p.pers_id,
        a.acc_id,
        a.acc_num,
        a.reg_date,
        to_char(a.start_date, 'MM/DD/YYYY')        start_date,
        to_char(a.end_date, 'MM/DD/YYYY')          end_date,
        p.gender,
        to_char(p.birth_date, 'MM/DD/YYYY')        birth_date,
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
        l.plan_name                                as plan_name,
        e.name                                     as insur_name -- add second param, dates to 4 fields below, for 2006 open in 2005
        ,
        i.deductible                               as deductible,
        pc_person.allow_deductible(p.pers_id,
                                   greatest(a.start_date, sysdate)) as allow_contr,
        pc_person.allow_deductible55(p.pers_id,
                                     greatest(a.start_date, sysdate)) as catch_up,
        pc_fin.allow_fee(a.acc_id,
                         greatest(a.start_date, sysdate))    as sum_fees,
        to_char(i.start_date, 'MM/DD/YYYY')        as start_ins,
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
        to_char((
            select
                max(effective_date)
            from
                broker_assignments
            where
                    broker_id = a.broker_id
                and pers_id = p.pers_id
        ),
                'MM/DD/YYYY')                      broker_effective_date,
        emp.name                                   employer,
        emp.entrp_contact                          emp_contact,
        emp.entrp_phones                           emp_phone,
        emp.entrp_email                            emp_email
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
        mail_type  mt,
        enterprise emp
    where
            a.pers_id = p.pers_id
        and p.entrp_id = ae.entrp_id (+) -- Person's Enterprise may has account
        and a.broker_id = b.broker_id
        and p.relat_code = r.relat_code (+)
        and p.pers_id = i.pers_id (+)
        and a.plan_code = l.plan_code
        and i.insur_id = e.entrp_id (+)
        and p.entrp_id = emp.entrp_id (+)
        and nvl(
            trunc((a.reg_date - p.birth_date) / 365.25),
            -1
        ) between low and hi
        and p.mailmet = mt.mail_code (+);

