-- liquibase formatted sql
-- changeset SAMQA:1754374172115 stripComments:false logicalFilePath:BASE_RELEASE\samqa\views\emp_overview_v.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/views/emp_overview_v.sql:null:4420c53df768ede929d1aba580f9dcde83f98183:create

create or replace force editionable view samqa.emp_overview_v (
    entrp_id,
    name,
    address,
    city,
    state,
    zip,
    acc_num,
    start_date,
    end_date,
    plan_code,
    plan_name,
    acc_id,
    no_of_employees,
    fee_setup,
    ein,
    account_type,
    account_status,
    broker_id,
    complete_flag,
    decline_date,
    enrolle_type,
    enrolled_by,
    signed_by,
    sign_type
) as
    select
        c.entrp_id,
        b.name,
        b.address,
        b.city,
        b.state,
        b.zip,
        c.acc_num,
        c.start_date,
        c.end_date,
        d.plan_code,
        d.plan_name,
        c.acc_id,
        case
            when c.account_type <> 'COBRA' then
                (
                    select
                        count(*)
                    from
                        person  d,
                        account e
                    where
                            d.pers_id = e.pers_id
                        and d.entrp_id = b.entrp_id
                        and e.account_status in ( 1, 2 )
                )
            else
                (
                    select
                        count(distinct pe.pers_id)
                    from
                        plan_elections pe,
                        person         a
                    where
                        pe.status in ( 'PR', 'P', 'E' )
                        and a.pers_id = pe.pers_id
                        and a.entrp_id = b.entrp_id
                )
        end                        no_of_employees,
        c.fee_setup,
        replace(b.entrp_code, '-') ein,
        c.account_type,
        c.account_status,
        c.broker_id,
        c.complete_flag,
        c.decline_date,
        c.enrolle_type,
        c.enrolled_by,  -------rprabu 9141
        c.signed_by,
        c.sign_type   ---  Sign_type and Signed_By rprabu 9141
    from
        enterprise b,
        account    c,
        plans      d
    where
            c.entrp_id = b.entrp_id
        and c.plan_code = d.plan_code;

