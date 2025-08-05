create or replace force editionable view samqa.claim_metrics_v (
    claim_id,
    claim_status,
    employer_name,
    received,
    received_days,
    benefits_received,
    entry_days,
    doc_received,
    reviewed_days,
    reviewed,
    released_days,
    released,
    payment_released_days,
    fin_released,
    funds_available_days,
    funds_avail_date,
    paid_days,
    payment_date,
    total,
    service_type,
    entrp_id,
    claim_date_start,
    claim_date_end
) as
    select
        a.claim_id,
        pc_lookups.get_claim_status(a.claim_status)                                                                       claim_status
        ,
        pc_entrp.get_entrp_name(a.entrp_id)                                                                               employer_name
        ,
        a.claim_date_start                                                                                                received,
        round(nvl(a.benefits_received_date, a.claim_date_start) - a.claim_date_start)                                     received_days
        ,
        a.benefits_received_date                                                                                          benefits_received
        ,
        round(pc_file_upload.get_creation_date(a.claim_id, 'CLAIMN') - nvl(a.benefits_received_date, a.claim_date_start)) entry_days,
        pc_file_upload.get_creation_date(a.claim_id, 'CLAIMN')                                                            doc_received
        ,
        round(a.reviewed_date - pc_file_upload.get_creation_date(a.claim_id, 'CLAIMN'))                                   reviewed_days
        ,
        a.reviewed_date                                                                                                   reviewed,
        round(a.released_date - a.reviewed_date)                                                                          released_days
        ,
        a.released_date                                                                                                   released,
        round(a.payment_release_date - a.released_date)                                                                   payment_released_days
        ,
        a.payment_release_date                                                                                            fin_released
        ,
        round(a.payment_release_date - nvl(a.funds_availability_date, a.payment_release_date))                            funds_available_days
        ,
        a.funds_availability_date                                                                                         funds_avail_date
        ,
        round(pc_claim.get_paid_date(a.claim_id) - a.payment_release_date)                                                paid_days,
        pc_claim.get_paid_date(a.claim_id)                                                                                payment_date
        ,
        round(pc_claim.get_paid_date(a.claim_id) - a.claim_date_start)                                                    total,
        a.service_type,
        a.entrp_id,
        a.claim_date_start,
        a.claim_date_end
    from
        claimn           a,
        payment_register b,
        account          c
    where
            a.pers_id = c.pers_id
        and b.acc_id = c.acc_id
        and a.claim_id = b.claim_id
        and c.account_type in ( 'HRA', 'FSA' )
        and b.pay_reason in ( 11, 12, 19 );


-- sqlcl_snapshot {"hash":"3642c6d8ce41133a0e42f4d3a17e7e6fffb94ef8","type":"VIEW","name":"CLAIM_METRICS_V","schemaName":"SAMQA","sxml":""}