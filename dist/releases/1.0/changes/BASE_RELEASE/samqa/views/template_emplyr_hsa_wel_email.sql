-- liquibase formatted sql
-- changeset SAMQA:1754374179653 stripComments:false logicalFilePath:BASE_RELEASE\samqa\views\template_emplyr_hsa_wel_email.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/views/template_emplyr_hsa_wel_email.sql:null:faf755b8ea09931b6e36ec3f003eaded5a81fe9b:create

create or replace force editionable view samqa.template_emplyr_hsa_wel_email (
    today,
    er_name,
    address,
    city,
    account_number,
    start_date,
    confirmation_date,
    email,
    user_name,
    template_name
) as
    select
        today,
        er_name,
        address,
        city,
        account_number,
        start_date,
        confirmation_date,
        email,
        user_name,
        template_name
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
                b.acc_num                      account_number,
                trunc(b.hsa_effective_date)    start_date,
                b.confirmation_date,
                nvl(e.email, a.entrp_email)    email,
                e.user_name,
                d.template_name
            from
                enterprise       a,
                account          b,
                plans            c,
                online_users     e,
                letter_templates d
            where
                    a.entrp_id = b.entrp_id
                and b.entrp_id is not null
                and b.account_type = 'HSA'
                and b.plan_code = c.plan_code
                and c.plan_sign = d.template_code
                and d.account_type = 'HSA'
                and d.template_type = 'EMPLOYER_HSA_WELCOME_EMAIL'
                and e.tax_id (+) = a.entrp_code
                and emp_reg_type (+) = 2
                and user_status (+) = 'A'
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
                b.acc_num                      account_number,
                trunc(b.hsa_effective_date)    start_date,
                b.confirmation_date,
                nvl(e.email, a.entrp_email)    email,
                e.user_name,
                d.template_name
            from
                enterprise       a,
                account          b,
                plans            c,
                online_users     e,
                letter_templates d
            where
                    a.entrp_id = b.entrp_id
                and b.entrp_id is not null
                and b.account_type = 'HSA'
                and b.plan_code = c.plan_code
                and c.plan_sign = d.template_code
                and d.account_type = 'HSA'
                and d.template_type = 'EMPLOYER_HSA_WELCOME_EMAIL'
                and e.tax_id (+) = a.entrp_code
                and emp_reg_type (+) = 2
                and user_status (+) = 'A'
                and d.entrp_id = b.entrp_id
        )
    where
        email is not null;

