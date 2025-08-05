create or replace force editionable view samqa.card_act (
    acc_id,
    card_id,
    adate,
    amount,
    claim_id,
    note
) as
    (
        select
            acc_id,
            card_id,
            transfer_date   as adate,
            transfer_amount as amount,
            to_number(null),
            note
        from
            card_transfer_acc
        union all
        select
            p.acc_id,
            c.pers_patient,
            p.pay_date,
            - p.amount,
            p.claimn_id,
            p.note
        from
            payment p,
            claimn  c
        where
                reason_code = 13
            and p.claimn_id = c.claim_id (+)
    );


-- sqlcl_snapshot {"hash":"af29af93cb094e7472afca729358a7c70c906e98","type":"VIEW","name":"CARD_ACT","schemaName":"SAMQA","sxml":""}