create or replace force editionable view samqa.emp_broker_assign_v (
    broker_assignment_id,
    broker_name,
    broker_lic,
    effective_date,
    effective_end_date,
    entrp_id,
    pers_id
) as
    select
        broker_assignment_id,
        e.first_name
        || ' '
        || e.last_name broker_name,
        d.broker_lic,
        a.effective_date,
        a.effective_end_date,
        a.entrp_id,
        a.pers_id
    from
        broker_assignments a,
        broker             d,
        person             e
    where
            d.broker_id = a.broker_id
        and e.pers_id = d.broker_id;


-- sqlcl_snapshot {"hash":"3d52031195ecef1648ba3ac3bd3593c3229e0655","type":"VIEW","name":"EMP_BROKER_ASSIGN_V","schemaName":"SAMQA","sxml":""}