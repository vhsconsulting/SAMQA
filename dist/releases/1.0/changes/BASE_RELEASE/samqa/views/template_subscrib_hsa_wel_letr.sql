-- liquibase formatted sql
-- changeset SAMQA:1754374179886 stripComments:false logicalFilePath:BASE_RELEASE\samqa\views\template_subscrib_hsa_wel_letr.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/views/template_subscrib_hsa_wel_letr.sql:null:19b7d7e36a3d50e5ba699414eb70ba113909120e:create

create or replace force editionable view samqa.template_subscrib_hsa_wel_letr (
    today,
    person_name,
    address,
    city,
    account_number,
    initial_contrib,
    month_setup,
    employer,
    start_date,
    single_contrib,
    family_contrib,
    confirmation_date,
    plan_code,
    template_name,
    created_by,
    acc_id,
    lang_perf
) as
    select
        today,
        person_name,
        address,
        city,
        account_number,
        initial_contrib,
        month_setup,
        employer,
        start_date,
        to_char(
            pc_param.get_system_value('INDIVIDUAL_CONTRIBUTION', sysdate),
            '9,999'
        ) single_contrib,
        to_char(
            pc_param.get_system_value('FAMILY_CONTRIBUTION', sysdate),
            '9,999'
        ) family_contrib,
        confirmation_date,
        plan_code,
        template_name,
        created_by,
        acc_id,
        lang_perf
    from
        (
            select
                to_char(sysdate, 'MM/DD/YYYY')                      today,
                a.first_name
                || ' '
                || a.middle_name
                || ' '
                || a.last_name                                      person_name,
                a.address                                           address,
                a.city
                || ' '
                || a.state
                || ' '
                || a.zip                                            city,
                b.acc_num                                           account_number,
                trim(to_char(
                    nvl(
                        pc_account.get_initial_contribution(b.acc_id),
                        nvl(b.start_amount, 0)
                    ),
                    '999999.99'
                ))                                                  initial_contrib,
                to_char(
                    pc_plan.fmonth(b.plan_code),
                    '9.99'
                )                                                   month_setup,
                (
                    select
                        name
                    from
                        enterprise
                    where
                        entrp_id = a.entrp_id
                )                                                   employer,
                trunc(greatest(c.start_date, b.hsa_effective_date)) start_date,
                b.confirmation_date,
                b.plan_code,
                d.template_name,
                a.created_by,
                b.acc_id,
                nvl(b.lang_perf, 'ENGLISH')                         lang_perf
            from
                person           a,
                account          b,
                insure           c,
                letter_templates d,
                plans            e
            where
                    a.pers_id = b.pers_id
                and b.account_status = 1
                and b.complete_flag = 1
                and b.account_type = 'HSA'
                and b.account_type = d.account_type
                and d.template_type = 'SUBSCRIBER_WELCOME_LETTER'
                and d.lang_pref = nvl(b.lang_perf, 'ENGLISH')
                and e.plan_code = b.plan_code
                and d.template_code = e.plan_sign
                and a.pers_id = c.pers_id
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
            union
            select
                to_char(sysdate, 'MM/DD/YYYY')                      today,
                a.first_name
                || ' '
                || a.middle_name
                || ' '
                || a.last_name                                      person_name,
                a.address                                           address,
                a.city
                || ' '
                || a.state
                || ' '
                || a.zip                                            city,
                b.acc_num                                           account_number,
                trim(to_char(
                    nvl(
                        pc_account.get_initial_contribution(b.acc_id),
                        nvl(b.start_amount, 0)
                    ),
                    '999999.99'
                ))                                                  initial_contrib,
                to_char(
                    pc_plan.fmonth(b.plan_code),
                    '9.99'
                )                                                   month_setup,
                (
                    select
                        name
                    from
                        enterprise
                    where
                        entrp_id = a.entrp_id
                )                                                   employer,
                trunc(greatest(c.start_date, b.hsa_effective_date)) start_date,
                b.confirmation_date,
                b.plan_code,
                d.template_name,
                a.created_by,
                b.acc_id,
                nvl(b.lang_perf, 'ENGLISH')                         lang_perf
            from
                person           a,
                account          b,
                insure           c,
                letter_templates d,
                plans            e
            where
                    a.pers_id = b.pers_id
                and b.account_status = 1
                and b.complete_flag = 1
                and b.account_type = 'HSA'
                and b.account_type = d.account_type
                and d.template_type = 'SUBSCRIBER_WELCOME_LETTER'
                and d.lang_pref = nvl(b.lang_perf, 'ENGLISH')
                and e.plan_code = b.plan_code
                and d.template_code = e.plan_sign
                and a.pers_id = c.pers_id
                and a.email is null
                and d.entrp_id = a.entrp_id
        )
    order by
        employer;

