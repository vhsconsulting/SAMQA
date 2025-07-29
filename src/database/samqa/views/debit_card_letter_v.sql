create or replace force editionable view samqa.debit_card_letter_v (
    name,
    address,
    city,
    zip,
    state,
    claim_id,
    employer_name,
    provider_name,
    service_date,
    amount
) as
    select distinct
        c.first_name
        || ' '
        || c.middle_name
        || ' '
        || c.last_name                name,
        c.address,
        c.city,
        c.zip,
        c.state,
        d.claim_id,
        replace(e.name, '&', ' and ') name,
        d.prov_name,
        to_char(d.service_start_date, 'mm/dd/yyyy'),
        d.claim_amount
    from
        account      b,
        person       c,
        claimn       d,
        online_users a,
        enterprise   e
    where
        b.pers_id is not null
        and b.pers_id = c.pers_id
        and c.email is null
        and c.pers_id = d.pers_id
        and c.entrp_id = e.entrp_id
        and d.unsubstantiated_flag = 'Y'
        and d.claim_status = 'PAID'
        and a.find_key (+) = b.acc_num
    --and (a.find_key is null OR b.acc_num = a.find_key)
    --AND b.acc_num IN ('ICA001024','ICA002134','FSA007413')
        and a.email is null
 -- AND TO_CHAR(d.creation_date,'dd-mm-RR') = TO_CHAR(sysdate,'dd-mm-RR')
        and b.account_type in ( 'HRA', 'FSA' );


-- sqlcl_snapshot {"hash":"cd21e9cc0dfea5facdffb02ea966e38417583714","type":"VIEW","name":"DEBIT_CARD_LETTER_V","schemaName":"SAMQA","sxml":""}