create or replace force editionable view samqa.cobra_renewal_v (
    name,
    acc_num,
    acc_id,
    entrp_id,
    account_type,
    no_of_eligible,
    plan_start_date,
    plan_end_date,
    broker_name,
    broker_id,
    ga_name,
    salesrep_id,
    ga_id,
    note,
    entrp_code,
    am,
    css_id
) as
    select
        b.name,
        a.acc_num,
        a.acc_id,
        a.entrp_id,
        a.account_type,
        b.no_of_eligible,
        bp.plan_end_date + 1                          plan_start_date,
        add_months(bp.plan_end_date, 12)              plan_end_date,
        pc_broker.get_broker_name(a.broker_id)        broker_name,
        a.broker_id,
        pc_sales_team.get_general_agent_name(a.ga_id) ga_name,
        a.salesrep_id,
        a.ga_id,
        b.note,
        b.entrp_code,
        nvl((
            select
                salesrep_id
            from
                salesrep d
            where
                    role_type = 'AM'
                and d.salesrep_id = a.am_id
        ), a.salesrep_id)                             am    /* Updated from a.salesrep_id  to a.am_id  sk 05/22/2018*/,
        (
            select
                entity_id
            from
                sales_team_member stm
            where
                    stm.emplr_id = a.entrp_id
                and stm.entity_type = 'CS_REP'
                and status = 'A'
                and stm.end_date is null
                and rownum = 1
        )                                             css_id
    from
        ben_plan_enrollment_setup bp,
        account                   a,
        enterprise                b
    where
            bp.acc_id = a.acc_id
        and a.entrp_id is not null
        and a.entrp_id = b.entrp_id
        and a.account_type = 'COBRA'
        and a.end_date is null
        and trunc(plan_end_date) = trunc(sysdate + 180)----sk updated from  90 to 180 days .
        and plan_start_date < sysdate
        and not exists (
            select
                *
            from
                ben_plan_enrollment_setup
            where
                    acc_id = a.acc_id
                and plan_end_date > bp.plan_end_date
        );


-- sqlcl_snapshot {"hash":"a90a29f24cbd04c0761d8e5f85c6698868f0a76e","type":"VIEW","name":"COBRA_RENEWAL_V","schemaName":"SAMQA","sxml":""}