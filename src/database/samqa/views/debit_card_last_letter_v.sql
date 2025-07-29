create or replace force editionable view samqa.debit_card_last_letter_v (
    name,
    address,
    city,
    zip,
    state,
    claim_id,
    service_date,
    provider_name,
    amount
) as
    select distinct
        replace(c.first_name
                || ' '
                || c.middle_name
                || ' '
                || c.last_name, '&', ' and ')               name,
        c.address,
        c.city,
        c.zip,
        c.state,
        d.claim_id,
        to_char(d.service_start_date, 'mm/dd/yyyy') service_date,
        d.prov_name                                 provider_name,
        d.claim_amount                              amount
    from
        account      b,
        person       c,
        claimn       d,
        online_users a
    where
        b.pers_id is not null
        and b.pers_id = c.pers_id
        and c.email is null
        and c.pers_id = d.pers_id
        and d.unsubstantiated_flag = 'Y'
        and d.claim_status = 'PAID'
        and a.find_key (+) = b.acc_num
    --AND b.acc_num IN ('ICA001024','ICA002134')
        and a.email is null
        and b.account_type in ( 'HRA', 'FSA' )
        and ( trunc(sysdate - d.creation_date) = 45 );


-- sqlcl_snapshot {"hash":"bf3b3c09d2d43f077ab0948ebb2f371f364be997","type":"VIEW","name":"DEBIT_CARD_LAST_LETTER_V","schemaName":"SAMQA","sxml":""}