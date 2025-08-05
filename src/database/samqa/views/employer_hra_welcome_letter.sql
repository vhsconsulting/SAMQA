create or replace force editionable view samqa.employer_hra_welcome_letter (
    today,
    er_name,
    er_contact,
    address,
    city,
    account_number,
    template_name,
    start_date,
    confirmation_date,
    acc_num,
    account_type,
    lang_perf
) as
    select
        today,
        er_name,
        er_contact,
        address,
        city,
        account_number,
        template_name,
        start_date,
        confirmation_date,
        acc_num,
        account_type,
        lang_perf
    from
        (
            select
                to_char(sysdate, 'MM/DD/YYYY')                  today,
                replace(a.name, '&', 'and')                     er_name,
                replace(a.entrp_contact, '&', 'and')            er_contact,
                replace(a.address, '&', 'and')                  address,
                replace(a.city, '&', 'and')
                || ' '
                || a.state
                || ' '
                || a.zip                                        city,
                b.bps_acc_num                                   account_number,
                trunc(b.reg_date)                               start_date,
                b.confirmation_date,
                d.template_name,
                b.acc_num,
                pc_benefit_plans.get_ben_account_type(b.acc_id) account_type,
                b.lang_perf
            from
                enterprise       a,
                account          b,
                plans            c,
                letter_templates d
            where
                    a.entrp_id = b.entrp_id
                and b.entrp_id is not null
                and b.account_type in ( 'HRA', 'FSA' )
                and d.account_type = pc_benefit_plans.get_ben_account_type(b.acc_id)
                and d.entrp_id is null
                and not exists (
                    select
                        *
                    from
                        letter_templates e
                    where
                        e.entrp_id = b.entrp_id
                )
                and d.lang_pref = nvl(b.lang_perf, 'ENGLISH')
                and b.plan_code = c.plan_code
                and c.plan_sign = d.template_code
                and d.template_type in ( 'EMPLOYER_HRA_WELCOME_LETTER', 'EMPLOYER_FSA_WELCOME_LETTER', 'EMPLOYER_HRA_FSA_WELCOME_LETTER'
                )
                and b.confirmation_date is null
            union
            select
                to_char(sysdate, 'MM/DD/YYYY')                  today,
                replace(a.name, '&', 'and')                     er_name,
                replace(a.entrp_contact, '&', 'and')            er_contact,
                replace(a.address, '&', 'and')                  address,
                replace(a.city, '&', 'and')
                || ' '
                || a.state
                || ' '
                || a.zip                                        city,
                b.bps_acc_num                                   account_number,
                trunc(b.reg_date)                               start_date,
                b.confirmation_date,
                d.template_name,
                b.acc_num,
                pc_benefit_plans.get_ben_account_type(b.acc_id) account_type,
                b.lang_perf
            from
                enterprise       a,
                account          b,
                plans            c,
                letter_templates d
            where
                    a.entrp_id = b.entrp_id
                and b.entrp_id is not null
                and b.account_type in ( 'HRA', 'FSA' )
                and d.account_type = pc_benefit_plans.get_ben_account_type(b.acc_id)
                and d.entrp_id = b.entrp_id
 --   AND NOT EXISTS ( SELECT * FROM LETTER_TEMPLATES E WHERE E.ENTRP_ID = B.ENTRP_ID)
                and d.lang_pref = nvl(b.lang_perf, 'ENGLISH')
                and b.plan_code = c.plan_code
                and c.plan_sign = d.template_code
                and d.template_type in ( 'EMPLOYER_HRA_WELCOME_LETTER', 'EMPLOYER_FSA_WELCOME_LETTER', 'EMPLOYER_HRA_FSA_WELCOME_LETTER'
                )
                and b.confirmation_date is null
        );


-- sqlcl_snapshot {"hash":"98a95e210cd85595088c59b95ceb9d80a6d62509","type":"VIEW","name":"EMPLOYER_HRA_WELCOME_LETTER","schemaName":"SAMQA","sxml":""}