create or replace force editionable view samqa.fsa_hra_sugar_v (
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
    date_closed,
    broker_name,
    broker_id,
    ga_id,
    ga_name,
    salesrep_id,
    note,
    am,
    css_id,
    ben_plan_number
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
        add_months(b.plan_end_date, 12)               date_closed -- Added by SK on 02_26_2019
        ,
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
        )                                             css_id,
        b.ben_plan_number
    from
        account                   a,
        ben_plan_enrollment_setup b,
        enterprise                c
    where
        account_type in ( 'FSA', 'HRA', 'ERISA_WRAP' )
        and a.acc_num = 'GFSA050771'
        and a.acc_id = b.acc_id
        and c.entrp_id = a.entrp_id
        and b.plan_end_date = '31-JAN-2022'
--   and   b.plan_end_date = '31-DEC-2016'
        and a.end_date is null
        and a.account_status = 1;


-- sqlcl_snapshot {"hash":"ada114085608f17e0c5518978e5e435497ba70ba","type":"VIEW","name":"FSA_HRA_SUGAR_V","schemaName":"SAMQA","sxml":""}