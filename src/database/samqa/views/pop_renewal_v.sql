create or replace force editionable view samqa.pop_renewal_v (
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
    rep_name,
    note,
    am,
    css_id
) as
    select
        c.name,
        a.acc_num,
        a.acc_id,
        b.ben_plan_id,
        a.entrp_id,
        a.account_type,
        c.no_of_eligible,
        c.entrp_code,
        add_months(b.plan_start_date, 12)             plan_start_date,
        add_months(b.plan_end_date, 12)               plan_end_date,
        pc_broker.get_broker_name(a.broker_id)        broker_name,
        a.broker_id,
        a.ga_id,
        pc_sales_team.get_general_agent_name(a.ga_id) ga_name,
        a.salesrep_id,
        pc_account.get_salesrep_name(a.salesrep_id)   rep_name,
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
            account_type = 'POP'
        and a.acc_id = b.acc_id
        and c.entrp_id = a.entrp_id
        and b.plan_type = 'NDT'
        and b.plan_end_date = trunc(sysdate + 180)
  -- and  b.plan_end_date BETWEEN '01-JUL-2016' AND '30-SEP-2016'
        and a.end_date is null
        and a.account_status = 1;


-- sqlcl_snapshot {"hash":"1860186862f9974b6accc822e68c39b95dad067a","type":"VIEW","name":"POP_RENEWAL_V","schemaName":"SAMQA","sxml":""}