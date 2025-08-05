create or replace force editionable view samqa.claim_denial_letters_v (
    entity_id,
    acc_num,
    event_id,
    employer_name,
    claim_amount,
    deductible_amount,
    denied_amount,
    claim_pending,
    claim_paid,
    claim_id,
    person_name,
    denied_reason,
    claim_status,
    event_name,
    address,
    address2,
    reviewed_date,
    service_start_date,
    prov_name
) as
    select
        e.entity_id,
        e.acc_num,
        e.event_id,
        nvl(
            pc_entrp.get_entrp_name(c.entrp_id),
            ''
        )                                           employer_name,
        nvl(c.claim_amount, '')                     claim_amount,
        nvl(c.deductible_amount, '')                deductible_amount,
        nvl(c.denied_amount, '')                    denied_amount,
        nvl(c.claim_pending, '')                    claim_pending,
        nvl(c.claim_paid, '')                       claim_paid,
        nvl(c.claim_id, '')                         claim_id,
        nvl(b.first_name, '')
        || ' '
        || nvl(b.middle_name, '')
        || ' '
        || nvl(b.last_name, '')                     person_name,
        case
            when c.denied_amount = 0
                 and c.deductible_amount > 0 then
                'Claim Applied towards deductible'
            else
                nvl(
                    pc_lookups.get_denied_reason(c.denied_reason),
                    ''
                )
        end                                         denied_reason,
        nvl(c.claim_status, '')                     claim_status,
        e.event_name,
        nvl(b.address, '')                          address,
        b.city
        || ' '
        || b.state
        || ' '
        || b.zip                                    address2,
        to_char(c.reviewed_date, 'MM/DD/YYYY')      reviewed_date,
        to_char(c.service_start_date, 'MM/DD/YYYY') service_start_date,
        c.prov_name                                 prov_name
    from
        event_notifications e,
        claimn              c,
        person              b
    where
        e.event_name in ( 'DEBIT_CLAIM_DENIAL', 'CLAIM_DENIAL' )
        and e.entity_id = c.claim_id
        and c.pers_id = b.pers_id
        and nvl(e.processed_flag, 'N') = 'N'
        and e.event_type = 'PAPER'
        and e.entity_type = 'CLAIMN';


-- sqlcl_snapshot {"hash":"cd6facd0f275ef306dd8d07662e6ad6312eaab68","type":"VIEW","name":"CLAIM_DENIAL_LETTERS_V","schemaName":"SAMQA","sxml":""}