-- liquibase formatted sql
-- changeset SAMQA:1754374179720 stripComments:false logicalFilePath:BASE_RELEASE\samqa\views\template_subscrib_hra_wel_letr.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/views/template_subscrib_hra_wel_letr.sql:null:dafbc7fcd36edb0d5e49c4b53cb5228d74880a74:create

create or replace force editionable view samqa.template_subscrib_hra_wel_letr (
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
    email
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
        email
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
                nvl(b.lang_perf, 'ENGLISH')                     lang_perf
            from
                person           a,
                account          b,
                letter_templates d,
                plans            e
            where
                    a.pers_id = b.pers_id
                and b.account_status = 1
                and b.complete_flag = 1
                and a.email is null
                and d.entrp_id is null
                and not exists (
                    select
                        *
                    from
                        letter_templates f
                    where
                        f.entrp_id = a.entrp_id
                )
                and b.account_type in ( 'HRA', 'FSA' )
                and d.lang_pref = nvl(b.lang_perf, 'ENGLISH')
                and d.account_type = pc_benefit_plans.get_ben_account_type(b.acc_id)
                and d.template_type in ( 'SUBSCRIBER_HRA_WELCOME_LETTER', 'SUBSCRIBER_FSA_WELCOME_LETTER', 'SUBSCRIBER_HRA_FSA_WELCOME_LETTER'
                )
                and e.plan_code = b.plan_code
                and d.template_code = e.plan_sign
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
                nvl(b.lang_perf, 'ENGLISH')                     lang_perf
            from
                person           a,
                account          b,
                letter_templates d,
                plans            e
            where
                    a.pers_id = b.pers_id
                and b.account_status = 1
                and b.complete_flag = 1
                and d.entrp_id = a.entrp_id
                and a.email is null
                and b.account_type in ( 'HRA', 'FSA' )
                and d.lang_pref = nvl(b.lang_perf, 'ENGLISH')
                and d.account_type = pc_benefit_plans.get_ben_account_type(b.acc_id)
                and d.template_type in ( 'SUBSCRIBER_HRA_WELCOME_LETTER', 'SUBSCRIBER_FSA_WELCOME_LETTER', 'SUBSCRIBER_HRA_FSA_WELCOME_LETTER'
                )
                and e.plan_code = b.plan_code
                and d.template_code = e.plan_sign
        )
    order by
        employer;

