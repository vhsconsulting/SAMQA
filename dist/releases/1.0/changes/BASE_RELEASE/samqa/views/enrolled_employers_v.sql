-- liquibase formatted sql
-- changeset SAMQA:1754374172699 stripComments:false logicalFilePath:BASE_RELEASE\samqa\views\enrolled_employers_v.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/views/enrolled_employers_v.sql:null:00fa400d221a101750531296916325be33a7ad49:create

create or replace force editionable view samqa.enrolled_employers_v (
    user_name,
    acc_num,
    name,
    ein_number,
    address,
    city,
    state,
    zip,
    phone,
    email,
    broker_lic,
    entrp_id,
    plan_code,
    plan_name,
    fee_setup,
    fee_maint,
    creation_date,
    account_status
) as
    select
        management_account_user_name user_name,
        c.acc_num,
        b.name,
        a.ein_number,
        b.address,
        b.city,
        b.state,
        b.zip,
        a.phone,
        a.email,
        a.broker_lic,
        a.entrp_id,
        a.plan_code,
        (
            select
                plan_name
            from
                plans
            where
                plans.plan_code = a.plan_code
        )                            plan_name,
        c.fee_setup,
        c.fee_maint,
        a.creation_date,
        c.account_status
    from
        employer_online_enrollment a,
        enterprise                 b,
        account                    c
    where
            a.entrp_id = b.entrp_id
        and b.entrp_id = c.entrp_id;

