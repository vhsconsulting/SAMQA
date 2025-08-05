-- liquibase formatted sql
-- changeset SAMQA:1754374172524 stripComments:false logicalFilePath:BASE_RELEASE\samqa\views\employer_hsa_welcome_email.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/views/employer_hsa_welcome_email.sql:null:cca69950b39d481f8c300c26993d09afa17346ed:create

create or replace force editionable view samqa.employer_hsa_welcome_email (
    today,
    er_name,
    address,
    city,
    account_number,
    start_date,
    confirmation_date,
    email,
    user_name
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
        user_name
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
                e.user_name
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
                and b.confirmation_date is null
                and e.tax_id (+) = a.entrp_code
                and emp_reg_type (+) = 2
                and user_status (+) = 'A'
        )
    where
        email is not null;

