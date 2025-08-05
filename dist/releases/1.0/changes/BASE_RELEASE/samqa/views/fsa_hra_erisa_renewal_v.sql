-- liquibase formatted sql
-- changeset SAMQA:1754374174438 stripComments:false logicalFilePath:BASE_RELEASE\samqa\views\fsa_hra_erisa_renewal_v.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/views/fsa_hra_erisa_renewal_v.sql:null:b19ad0d14c4805dc29f31111b294eed675ba8a94:create

create or replace force editionable view samqa.fsa_hra_erisa_renewal_v (
    name,
    acc_num,
    acc_id,
    ben_plan_id,
    entrp_id,
    account_type,
    no_of_eligible,
    entrp_code,
    plan_start_date,
    plan_end_date,
    broker_name,
    broker_id,
    ga_id,
    ga_name,
    salesrep_id,
    note,
    am,
    css_id
) as
    select distinct
        c.name,
        a.acc_num,
        a.acc_id,
        b.ben_plan_id,
        a.entrp_id,
        a.account_type,
        c.no_of_eligible,
        c.entrp_code,
        b.plan_end_date + 1                           plan_start_date,
        add_months(b.plan_end_date, 12)               plan_end_date,
        pc_broker.get_broker_name(a.broker_id)        broker_name,
        a.broker_id,
        a.ga_id,
        pc_sales_team.get_general_agent_name(a.ga_id) ga_name,
        a.salesrep_id,
        b.note,
        nvl((
            select
                salesrep_id
            from
                salesrep d
            where
                    role_type = 'AM'
                and d.salesrep_id = a.am_id
        ), a.salesrep_id)                             am /* Updated from a.salesrep_id  to a.am_id sk 05/22/2018*/,
        (
            select
                entity_id
            from
                sales_team_member
            where
                    emplr_id = a.entrp_id
                and entity_type = 'CS_REP'
                and status = 'A'
                and end_date is null
                and rownum = 1
        )                                             css_id
    from
        account                   a,
        ben_plan_enrollment_setup b,
        enterprise                c
    where
        account_type in ( 'FSA', 'HRA', 'ERISA_WRAP', 'FORM_5500' )
        and a.acc_id = b.acc_id
        and c.entrp_id = a.entrp_id
        and b.plan_end_date = trunc(sysdate + 90)
--   and   b.plan_end_date = '31-DEC-2016'
        and a.end_date is null
        and a.account_status = 1;

