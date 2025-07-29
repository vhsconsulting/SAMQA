create or replace force editionable view samqa.invoice_rate_plans_v (
    entrp_id,
    plan_type,
    reason_code,
    reason_name,
    rate_basis
) as
    with inv_fees as (
        select
            entrp_id,
            x.plan_type,
            reason_code,
            reason_name
        from
            (
                select
                    entrp_id,
                    case
                        when fsa_cnt > 1
                             and trn_cnt > 0 then
                            'FSA_COMBO'
                        when fsa_cnt > 1
                             and trn_cnt = 0 then
                            'FSA_COMBO'
                        when fsa_cnt = 0
                             and trn_cnt > 0 then
                            'TRN_PKG'
                    end plan_type
                from
                    (
                        select
                            e.entrp_id,
                            sum(
                                case
                                    when a.plan_type in('FSA', 'DCA', 'IIR', 'LPF') then
                                        1
                                    else
                                        0
                                end
                            ) fsa_cnt,
                            sum(
                                case
                                    when a.plan_type in('TRN', 'PKG', 'UA1', 'TP2') then
                                        1
                                    else
                                        0
                                end
                            ) trn_cnt
                        from
                            ben_plan_enrollment_setup a,
                            enterprise                e,
                            account                   c
                        where
                                a.entrp_id = e.entrp_id
                            and a.plan_end_date > sysdate
                            and a.acc_id = c.acc_id
                            and c.account_type in ( 'HRA', 'FSA' )
                            and a.product_type = 'FSA'
                        group by
                            e.entrp_id
                    )
            )          x,
            pay_reason p
        where
                x.plan_type = p.plan_type
            and p.reason_mapping = 2
        union
        select
            e.entrp_id,
            a.plan_type,
            d.reason_code,
            reason_name
        from
            ben_plan_enrollment_setup a,
            enterprise                e,
            account                   c,
            pay_reason                d
        where
                a.entrp_id = e.entrp_id
            and a.plan_end_date > sysdate
            and a.acc_id = c.acc_id
            and c.account_type in ( 'HRA', 'FSA' )
            and a.product_type = 'FSA'
            and d.plan_type = a.plan_type
            and d.reason_mapping = 2
        union
        select
            e.entrp_id,
            a.plan_type,
            d.reason_code,
            reason_name
        from
            ben_plan_enrollment_setup a,
            enterprise                e,
            account                   c,
            pay_reason                d
        where
                a.entrp_id = e.entrp_id
            and a.plan_end_date > sysdate
            and a.acc_id = c.acc_id
            and c.account_type in ( 'HRA', 'FSA' )
            and a.product_type = 'HRA'
            and d.plan_type = a.product_type
            and d.reason_mapping = 2
    ), rate_b as (
        select
            'ACTIVE' rate_basis
        from
            dual
        union
        select
            'RUNOUT' rate_basis
        from
            dual
    )
    select
        entrp_id,
        plan_type,
        reason_code,
        reason_name,
        rate_basis
    from
        inv_fees,
        rate_b;


-- sqlcl_snapshot {"hash":"825faf375611ddb59e1020c2791f54d9924cec67","type":"VIEW","name":"INVOICE_RATE_PLANS_V","schemaName":"SAMQA","sxml":""}