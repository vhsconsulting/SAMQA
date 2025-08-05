-- liquibase formatted sql
-- changeset SAMQA:1754374172183 stripComments:false logicalFilePath:BASE_RELEASE\samqa\views\emp_quarterly_email_v.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/views/emp_quarterly_email_v.sql:null:73e13102bc5a5c753cbec6559dee168424744d9a:create

create or replace force editionable view samqa.emp_quarterly_email_v (
    rn,
    email,
    acc_num,
    end_date,
    plan_code,
    entrp_id
) as
    select
        rownum rn,
        email,
        p.acc_num,
        p.end_date,
        p.plan_code,
        p.entrp_id
    from
        online_users u,
        account      p,
        enterprise   a
    where
            user_type = 'E'
        and emp_reg_type = 2
        and u.user_status = 'A'
        and p.account_status = 1
        and a.entrp_id = p.entrp_id
        and replace(a.entrp_code, '-') = u.tax_id
        and p.end_date is null
        and p.account_type = 'HSA'
        and p.plan_code in ( 1, 2, 3, 4, 5,
                             6, 7, 8 )
    order by
        p.end_date asc;

