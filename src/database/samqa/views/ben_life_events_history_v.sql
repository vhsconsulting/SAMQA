create or replace force editionable view samqa.ben_life_events_history_v (
    effective_date,
    life_event,
    annual_election,
    acc_id
) as
    select
        to_char(
            decode(bps.effective_end_date, null, bleh.effective_date, bps.effective_end_date),
            'MM/DD/YYYY'
        )                            effective_date,
        bps.plan_type
        || ' - '
        || l.description             life_event,
        nvl(bleh.annual_election, 0) annual_election,
        bps.acc_id                   acc_id
    from
        ben_life_event_history    bleh,
        lookups                   l,
        ben_plan_enrollment_setup bps
    where
            bleh.life_event_code = l.lookup_code
        and bps.status <> 'R'
        and bps.ben_plan_id = bleh.ben_plan_id
        and bleh.life_event_code not in ( 'TERM_ONE_PLAN', 'TERM_ALL_PLAN', 'COBRA', 'ACCOUNT_TERMINATION' )
        and trunc(bps.plan_end_date) > trunc(sysdate)
        and l.lookup_name = 'LIFE_EVENT_CODE'
    union all
    select
        to_char(
            decode(bps.effective_end_date, null, ti.termination_date, bps.effective_end_date),
            'MM/DD/YYYY'
        )                    effective_date,
        bps.plan_type
        || ' - '
        || 'Plan Terminated' life_event,
        0                    annual_election,
        bps.acc_id           acc_id
    from
        termination_interface     ti,
        ben_plan_enrollment_setup bps
    where
            trunc(bps.plan_end_date) > trunc(sysdate)
        and ti.ben_plan_id = bps.ben_plan_id
        and bps.status <> 'R'
        and not exists (
            select
                1
            from
                ben_life_event_history    bleh1,
                ben_plan_enrollment_setup bps1
            where
                    bps1.ben_plan_id = bleh1.ben_plan_id
                and bleh1.life_event_code = 'TERM_ALL_PLAN'
                and bps1.status <> 'R'
                and trunc(bps1.plan_end_date) > trunc(sysdate)
                and bps1.acc_id = bps.acc_id
        )
    union all
    select
        to_char(
            decode(bps.effective_end_date, null, bleh.effective_date, bps.effective_end_date),
            'MM/DD/YYYY'
        ),
        l.description                life_event,
        nvl(bleh.annual_election, 0) annual_election,
        bps.acc_id                   acc_id
    from
        ben_life_event_history    bleh,
        ben_plan_enrollment_setup bps,
        lookups                   l
    where
            bps.ben_plan_id = bleh.ben_plan_id
        and bleh.life_event_code in ( 'TERM_ALL_PLAN', 'COBRA' )
        and trunc(bps.plan_end_date) > trunc(sysdate)
        and bleh.life_event_code = l.lookup_code
        and bps.status <> 'R'
        and l.lookup_name = 'LIFE_EVENT_CODE';


-- sqlcl_snapshot {"hash":"4396e12d97dca04af85abe4ab2baf115d55f0c81","type":"VIEW","name":"BEN_LIFE_EVENTS_HISTORY_V","schemaName":"SAMQA","sxml":""}