-- liquibase formatted sql
-- changeset SAMQA:1754374172604 stripComments:false logicalFilePath:BASE_RELEASE\samqa\views\employer_welcome_letter.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/views/employer_welcome_letter.sql:null:ce2046f459c3cd2cdd5d587bf7ed8a49aeb5b776:create

create or replace force editionable view samqa.employer_welcome_letter (
    today,
    er_name,
    address,
    city,
    account_number,
    template_name,
    start_date,
    confirmation_date,
    lang_perf,
    er_contact
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
                and b.confirmation_date is null
                and a.entrp_email is null
	/*Ticket#6588.Eliminate employers who have online users.They will get separate emails */
                and not exists (
                    select
                        *
                    from
                        online_users b
                    where
                            a.entrp_code = b.tax_id
                        and b.emp_reg_type = 2
                        and b.user_status = 'A'
                )
        );

