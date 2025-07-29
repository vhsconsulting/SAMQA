create or replace force editionable view samqa.claim_analytics_v (
    pay_date,
    amount,
    reason_name,
    employer_name,
    er_acc_num
) as
    select
        to_char(p.pay_date, 'MM/YYYY')      pay_date,
        sum(nvl(p.amount, 0))               amount,
        pr.reason_name,
        pc_entrp.get_entrp_name(p.entrp_id) employer_name,
        pc_entrp.get_acc_num(p.entrp_id)    er_acc_num
    from
        payment    p,
        account    ac,
        person     p,
        pay_reason pr
    where
            p.acc_id = ac.acc_id
        and ac.account_type = 'HSA'
        and p.pers_id = ac.pers_id
        and pr.reason_code = p.reason_code
        and pr.reason_type = 'DISBURSEMENT'
    group by
        to_char(p.pay_date, 'MM/YYYY'),
        pr.reason_name,
        p.entrp_id,
        p.entrp_id;


-- sqlcl_snapshot {"hash":"91c2d17d496804ba590e63b7c52dbb44ae633c18","type":"VIEW","name":"CLAIM_ANALYTICS_V","schemaName":"SAMQA","sxml":""}