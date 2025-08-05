create or replace force editionable view samqa.template_employer_hra_wel_letr (
    today,
    er_name,
    er_contact,
    address,
    city,
    bps_acc_num,
    template_name,
    start_date,
    confirmation_date,
    account_number,
    account_type,
    lang_perf
) as
    select
        today,
        er_name,
        er_contact,
        address,
        city,
        bps_acc_num,
        template_name,
        start_date,
        confirmation_date,
        account_number,
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
                b.bps_acc_num,
                trunc(b.reg_date)                               start_date,
                b.confirmation_date,
                d.template_name,
                b.acc_num                                       account_number,
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
                and d.account_type = nvl(
                    pc_benefit_plans.get_ben_account_type(b.acc_id),
                    b.account_type
                )
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
                b.bps_acc_num,
                trunc(b.reg_date)                               start_date,
                b.confirmation_date,
                d.template_name,
                b.acc_num                                       account_number,
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
                and d.account_type = nvl(
                    pc_benefit_plans.get_ben_account_type(b.acc_id),
                    b.account_type
                )
                and d.entrp_id = b.entrp_id
                and d.lang_pref = nvl(b.lang_perf, 'ENGLISH')
                and b.plan_code = c.plan_code
                and c.plan_sign = d.template_code
                and d.template_type in ( 'EMPLOYER_HRA_WELCOME_LETTER', 'EMPLOYER_FSA_WELCOME_LETTER', 'EMPLOYER_HRA_FSA_WELCOME_LETTER'
                )
        );


-- sqlcl_snapshot {"hash":"41fa83dbd4e875d09f931f43fac3f46826ce7d02","type":"VIEW","name":"TEMPLATE_EMPLOYER_HRA_WEL_LETR","schemaName":"SAMQA","sxml":""}