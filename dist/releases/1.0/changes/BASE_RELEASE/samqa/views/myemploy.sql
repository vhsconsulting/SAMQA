-- liquibase formatted sql
-- changeset SAMQA:1754374177053 stripComments:false logicalFilePath:BASE_RELEASE\samqa\views\myemploy.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/views/myemploy.sql:null:3a927672681812d78da408477a44fddf3b9216d8:create

create or replace force editionable view samqa.myemploy (
    entrp_id,
    name,
    address,
    city,
    state,
    zip,
    ein,
    broker_lic,
    fee_setup,
    fee_maint,
    group_n,
    contact_phone,
    contact_email,
    contact_name,
    term,
    broker_effective_date,
    start_date,
    agency_name,
    acc_id,
    broker_name
) as
    select
        e.entrp_id,
        substr(e.name, 1, 60)                  as name,
        substr(e.address, 1, 40)               as address,
        e.city,
        e.state,
        e.zip,
        e.entrp_code                           as ein,
        nvl(b.broker_lic, 'SK' || b.broker_id) as broker_lic,
        pc_plan.fsetup(a.plan_code)            fee_setup,
        pc_plan.fmonth(a.plan_code)            as fee_maint,
        a.acc_num                              as group_n,
        substr(entrp_phones, 1, 30)            contact_phone,
        substr(entrp_email, 1, 40)             contact_email,
        substr(entrp_contact, 1, 40)           contact_name,
        null                                   as term,
        (
            select
                min(effective_date)
            from
                broker_assignments
            where
                    entrp_id = e.entrp_id
                and broker_id = b.broker_id
                and pers_id is null
        )                                      broker_effective_date,
        a.start_date,
        b.agency_name,
        a.acc_id,
        (
            select
                first_name
                || ' '
                || last_name
            from
                person
            where
                person.pers_id = b.broker_id
        )                                      broker_name
    from
        enterprise e,
        account    a,
        broker     b
    where
            e.entrp_id = a.entrp_id
        and a.broker_id = b.broker_id;

