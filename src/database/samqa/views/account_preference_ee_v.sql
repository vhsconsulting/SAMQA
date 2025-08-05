create or replace force editionable view samqa.account_preference_ee_v (
    claim_payment_method,
    autopay_ind,
    acc_id,
    pers_id,
    entrp_id,
    er_acc_id,
    er_acc_num,
    ee_acc_num
) as
    select
        er.claim_payment_method,
        er.autopay_ind,
        eeacc.acc_id,
        c.pers_id,
        eracc.entrp_id,
        eracc.acc_id  er_acc_id,
        eracc.acc_num er_acc_num,
        eeacc.acc_num ee_acc_num
    from
        account_preference er,
        account            eracc,
        person             c,
        account            eeacc
    where
            er.acc_id = eracc.acc_id
        and eracc.entrp_id = c.entrp_id
        and c.pers_id = eeacc.pers_id
        and er.status = 'A';


-- sqlcl_snapshot {"hash":"5b03c37ce78a9babedfb4384cd691af847305aa5","type":"VIEW","name":"ACCOUNT_PREFERENCE_EE_V","schemaName":"SAMQA","sxml":""}