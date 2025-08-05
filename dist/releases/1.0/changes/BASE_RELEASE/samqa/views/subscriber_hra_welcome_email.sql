-- liquibase formatted sql
-- changeset SAMQA:1754374178942 stripComments:false logicalFilePath:BASE_RELEASE\samqa\views\subscriber_hra_welcome_email.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/views/subscriber_hra_welcome_email.sql:null:6ede0d0689479a7287b734d6175ed3447712b8d7:create

create or replace force editionable view samqa.subscriber_hra_welcome_email (
    today,
    person_name,
    address,
    city,
    account_number,
    employer,
    start_date,
    confirmation_date,
    plan_code,
    template_name,
    created_by,
    acc_id,
    account_type,
    lang_perf,
    reg_date,
    email,
    subject,
    entrp_email,
    employer_name
) as
    select
        today,
        person_name,
        address,
        city,
        account_number,
        employer,
        start_date,
        confirmation_date,
        plan_code,
        template_name,
        created_by,
        acc_id,
        account_type,
        lang_perf,
        reg_date,
        email,
        decode(account_type, 'FSA', 'Your Sterling Account Information for '
                                    || employer_name
                                    || ''''
                                    || 's Flexible Benefits Account', 'HRA', 'Your Sterling Account Information for '
                                                                             || employer_name
                                                                             || ''''
                                                                             || ' s Health Reimbursement Arrangement Account',
               'HRAFSA', 'Your Sterling Account Information for '
                         || employer_name
                         || ''''
                         || 's Health Reimbursement Arrangement and Flexible Benefits Account') subject,
        entrp_email,
        employer_name
    from
        (
            select
                to_char(sysdate, 'MM/DD/YYYY')                  today,
                a.first_name
                || ' '
                || a.middle_name
                || ' '
                || a.last_name                                  person_name,
                a.address                                       address,
                a.city
                || ' '
                || a.state
                || ' '
                || a.zip                                        city,
                b.acc_num                                       account_number,
                pc_entrp.get_acc_num(a.entrp_id)                employer,
                b.start_date,
                b.reg_date,
                b.confirmation_date,
                b.plan_code,
                d.template_name,
                a.created_by,
                a.email,
                b.acc_id,
                pc_benefit_plans.get_ben_account_type(b.acc_id) account_type,
                nvl(b.lang_perf, 'ENGLISH')                     lang_perf,
                ep.entrp_email                                  entrp_email,
                ep.name                                         employer_name
            from
                person           a,
                account          b,
                letter_templates d,
                plans            e,
                enterprise       ep
            where
                    a.pers_id = b.pers_id
                and a.entrp_id = ep.entrp_id
                and b.account_status = 1
                and b.complete_flag = 1
                and b.confirmation_date is null
                and a.email is not null
                and b.account_type in ( 'HRA', 'FSA' )
                and not exists (
                    select
                        *
                    from
                        letter_templates f
                    where
                        f.entrp_id = a.entrp_id
                )
                and d.lang_pref = nvl(b.lang_perf, 'ENGLISH')
                and d.account_type = pc_benefit_plans.get_ben_account_type(b.acc_id)
                and d.template_type in ( 'SUBSCRIBER_HRA_WELCOME_EMAIL', 'SUBSCRIBER_FSA_WELCOME_EMAIL', 'SUBSCRIBER_HRAFSA_WELCOME_EMAIL'
                )
                and e.plan_code = b.plan_code
                and d.template_code = e.plan_sign
                and a.email is not null
                and d.entrp_id is null
            union
            select
                to_char(sysdate, 'MM/DD/YYYY')                  today,
                a.first_name
                || ' '
                || a.middle_name
                || ' '
                || a.last_name                                  person_name,
                a.address                                       address,
                a.city
                || ' '
                || a.state
                || ' '
                || a.zip                                        city,
                b.acc_num                                       account_number,
                pc_entrp.get_acc_num(a.entrp_id)                employer,
                b.start_date,
                b.reg_date,
                b.confirmation_date,
                b.plan_code,
                d.template_name,
                a.created_by,
                a.email,
                b.acc_id,
                pc_benefit_plans.get_ben_account_type(b.acc_id) account_type,
                nvl(b.lang_perf, 'ENGLISH')                     lang_perf,
                ep.entrp_email                                  entrp_email,
                ep.name                                         employer_name
            from
                person           a,
                account          b,
                letter_templates d,
                plans            e,
                enterprise       ep
            where
                    a.pers_id = b.pers_id
                and b.account_status = 1
                and b.complete_flag = 1
                and b.confirmation_date is null
                and ep.entrp_id = a.entrp_id
                and d.entrp_id = a.entrp_id
                and a.email is not null
                and b.account_type in ( 'HRA', 'FSA' )
                and d.lang_pref = nvl(b.lang_perf, 'ENGLISH')
                and d.account_type = pc_benefit_plans.get_ben_account_type(b.acc_id)
                and d.template_type in ( 'SUBSCRIBER_FSA_WELCOME_EMAIL', 'SUBSCRIBER_HRA_WELCOME_EMAIL', 'SUBSCRIBER_HRA_FSA_WELCOME_EMAIL'
                )
                and e.plan_code = b.plan_code
                and d.template_code = e.plan_sign
        )
    order by
        employer;

