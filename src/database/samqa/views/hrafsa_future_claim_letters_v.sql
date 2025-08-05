create or replace force editionable view samqa.hrafsa_future_claim_letters_v (
    entity_id,
    acc_num,
    event_id,
    employer_name,
    claim_amount,
    claim_id,
    person_name,
    address,
    address2,
    today_date,
    plan_type
) as
    select
        e.entity_id,
        e.acc_num,
        e.event_id,
        pc_entrp.get_entrp_name(c.entrp_id) employer_name,
        nvl(c.claim_amount, '')             claim_amount,
        nvl(c.claim_id, '')                 claim_id,
        nvl(b.first_name, '')
        || ' '
        || nvl(b.middle_name, '')
        || ' '
        || nvl(b.last_name, '')             person_name,
        nvl(b.address, '')                  address,
        b.city
        || ' '
        || b.state
        || ' '
        || b.zip                            address2,
        to_char(sysdate, 'MM/DD/YYYY')      today_date,
        c.service_type                      plan_type
    from
        event_notifications e,
        claimn              c,
        person              b
    where
        e.event_name in ( 'HRAFSA_FUTURE_CLAIM' )
        and e.entity_id = c.claim_id
        and c.pers_id = b.pers_id
        and nvl(e.processed_flag, 'N') = 'N'
        and e.event_type = 'PAPER'
        and e.entity_type = 'CLAIMN';


-- sqlcl_snapshot {"hash":"bad4df01cd9abc110231e35c0726d51003e0eb41","type":"VIEW","name":"HRAFSA_FUTURE_CLAIM_LETTERS_V","schemaName":"SAMQA","sxml":""}