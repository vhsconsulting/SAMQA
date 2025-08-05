create or replace force editionable view samqa.template_employer_hsa_wel_letr (
    today,
    er_name,
    address,
    city,
    account_number,
    template_name,
    start_date,
    confirmation_date,
    lang_perf,
    entrp_contact
) as
    select
        today,
        er_name,
        address,
        city,
        account_number,
        template_name,
        start_date,
        confirmation_date,
        lang_perf,
        entrp_contact
    from
        (
            select
                to_char(sysdate, 'MM/DD/YYYY') today,
                a.name                         er_name,
                a.address                      address,
                a.city
                || ' '
                || a.state
                || ' '
                || a.zip                       city,
                a.entrp_contact,
                b.acc_num                      account_number,
                trunc(b.hsa_effective_date)    start_date,
                b.confirmation_date,
                d.template_name,
                nvl(b.lang_perf, 'ENGLISH')    lang_perf
            from
                enterprise       a,
                account          b,
                plans            c,
                letter_templates d
            where
                    a.entrp_id = b.entrp_id
                and b.entrp_id is not null
                and b.account_type = 'HSA'
                and b.account_type = d.account_type
                and d.lang_pref = nvl(b.lang_perf, 'ENGLISH')
                and b.plan_code = c.plan_code
                and c.plan_sign = d.template_code
                and d.template_type = 'EMPLOYER_WELCOME_LETTER'
                and d.entrp_id is null
                and not exists (
                    select
                        *
                    from
                        letter_templates e
                    where
                        e.entrp_id = b.entrp_id
                )
            union
            select
                to_char(sysdate, 'MM/DD/YYYY') today,
                a.name                         er_name,
                a.address                      address,
                a.city
                || ' '
                || a.state
                || ' '
                || a.zip                       city,
                a.entrp_contact,
                b.acc_num                      account_number,
                trunc(b.hsa_effective_date)    start_date,
                b.confirmation_date,
                d.template_name,
                nvl(b.lang_perf, 'ENGLISH')    lang_perf
            from
                enterprise       a,
                account          b,
                plans            c,
                letter_templates d
            where
                    a.entrp_id = b.entrp_id
                and b.entrp_id is not null
                and b.account_type = 'HSA'
                and b.account_type = d.account_type
                and d.lang_pref = nvl(b.lang_perf, 'ENGLISH')
                and b.plan_code = c.plan_code
                and c.plan_sign = d.template_code
                and d.template_type = 'EMPLOYER_WELCOME_LETTER'
                and d.entrp_id = b.entrp_id
        );


-- sqlcl_snapshot {"hash":"31b9bcd976d43b2da42890dcabdeb9a9b226e854","type":"VIEW","name":"TEMPLATE_EMPLOYER_HSA_WEL_LETR","schemaName":"SAMQA","sxml":""}