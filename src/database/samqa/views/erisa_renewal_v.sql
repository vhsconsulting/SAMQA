create or replace force editionable view samqa.erisa_renewal_v (
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
        add_months(x.start_date, 12) - 1              plan_start_date,
        add_months(
            add_months(x.start_date, 12),
            12
        ) - 1                                         plan_end_date,
        pc_broker.get_broker_name(a.broker_id)        broker_name,
        a.broker_id,
        pc_sales_team.get_general_agent_name(a.ga_id) ga_name,
        a.salesrep_id,
        a.ga_id,
        b.note,
        b.entrp_code,
        (
            select
                salesrep_id
            from
                salesrep d
            where
                    role_type = 'AM'
                and d.salesrep_id = a.salesrep_id
        )                                             am,
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
        (
            select
                max(a.start_date) start_date,
                b.acc_id,
                b.acc_num,
                b.account_status,
                b.entrp_id
            from
                ar_invoice       a,
                account          b,
                ar_invoice_lines c
            where
                    b.account_type = 'COBRA'
                and c.rate_code in ( '1', '30' )
                and a.acc_id = b.acc_id
                and a.invoice_id = c.invoice_id
                and b.account_status = 1
                and not exists (
                    select
                        *
                    from
                        ben_plan_renewals
                    where
                            acc_id = b.acc_id
                        and end_date > sysdate
                )
            group by
                b.acc_id,
                b.acc_num,
                b.account_status,
                b.entrp_id
            having
                add_months(
                    max(a.start_date),
                    12
                ) - 1 between sysdate + 90 and sysdate + 100
        )          x,
        account    a,
        enterprise b
    where
            x.entrp_id = b.entrp_id
        and a.entrp_id = b.entrp_id;


-- sqlcl_snapshot {"hash":"d20050eb3d20db368d2510e7ac7ca4b8337cab71","type":"VIEW","name":"ERISA_RENEWAL_V","schemaName":"SAMQA","sxml":""}