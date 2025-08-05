create or replace force editionable view samqa.hrafsa_claim_metrics_v (
    claim_id,
    acc_num,
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
    claim_date_end,
    account_type,
    claim_stat_code,
    denied_reason,
    claim_source
) as
    select
        a.claim_id,
        b.acc_num,
        pc_lookups.get_claim_status(a.claim_status)                       claim_status,
        pc_entrp.get_entrp_name(a.entrp_id)                               employer_name,
        a.claim_date_start                                                received,
        round(num_business_days(a.claim_date_start,
                                nvl(a.benefits_received_date, a.claim_date_start)))     received_days,
        a.benefits_received_date                                          benefits_received,
        round(num_business_days(
            nvl(a.benefits_received_date, a.claim_date_start),
            pc_file_upload.get_creation_date(a.claim_id, 'CLAIMN')
        ))                                                                entry_days,
        pc_file_upload.get_creation_date(a.claim_id, 'CLAIMN')            doc_received,
        round(num_business_days(
            pc_file_upload.get_creation_date(a.claim_id, 'CLAIMN'),
            a.reviewed_date
        ))                                                                reviewed_days,
        a.reviewed_date                                                   reviewed,
        round(num_business_days(a.reviewed_date, a.released_date))        released_days,
        a.released_date                                                   released,
        round(num_business_days(a.released_date, a.payment_release_date)) payment_released_days,
        a.payment_release_date                                            fin_released,
        round(num_business_days(
            nvl(a.funds_availability_date, a.payment_release_date),
            a.payment_release_date
        ))                                                                funds_available_days,
        a.funds_availability_date                                         funds_avail_date,
        round(num_business_days(a.payment_release_date,
                                pc_claim.get_paid_date(a.claim_id)))                    paid_days,
        pc_claim.get_paid_date(a.claim_id)                                payment_date,
        round(num_business_days(a.claim_date_start,
                                pc_claim.get_paid_date(a.claim_id)))                    total,
        a.service_type,
        a.entrp_id,
        a.claim_date_start,
        a.claim_date_end,
        c.account_type,
        a.claim_status                                                    claim_stat_code,
        a.denied_reason,
        case
            when b.claim_type in ( 'SUBSCRIBER', 'PROVIDER' ) then
                'In office'
            else
                'Online'
        end                                                               claim_source
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


-- sqlcl_snapshot {"hash":"1dfbaab6fb9b2736ce3dd37e39785248ed20202d","type":"VIEW","name":"HRAFSA_CLAIM_METRICS_V","schemaName":"SAMQA","sxml":""}