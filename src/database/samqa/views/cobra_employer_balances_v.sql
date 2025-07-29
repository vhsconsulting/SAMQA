create or replace force editionable view samqa.cobra_employer_balances_v (
    rn,
    entrp_id,
    acc_id,
    transaction_type,
    check_amount,
    transaction_date,
    fee_name,
    note,
    employer_payment_id,
    creaton_date
) as
    select
        rownum                        rn,
        entrp_id,
        pc_entrp.get_acc_id(entrp_id) acc_id,
        transaction_type,
        check_amount,
        transaction_date,
        fee_name,
        note,
        employer_payment_id,
        creation_date
    from
        (
            select
                a.entrp_id,
                'RECEIPT'              transaction_type,
                check_amount,
                trunc(check_date)      transaction_date,
                b.fee_name,
                a.note,
                a.employer_deposit_id  employer_payment_id,
                trunc(a.creation_date) creation_date
            from
                employer_deposits a,
                fee_names         b,
                account           c
            where
                    a.reason_code = b.fee_code
                and a.reason_code = 95
                and a.entrp_id = c.entrp_id
                and c.account_type = 'COBRA'
            union all
            select
                ep.entrp_id,
                'PAYMENT',
                - ep.check_amount,
                trunc(transaction_date),
                pr.reason_name,
                ep.note,
                ep.employer_payment_id,
                trunc(ep.creation_date) creation_date
            from
                employer_payments ep,
                account           c,
                pay_reason        pr,
                cobra_payments    cp
            where
                    ep.entrp_id = c.entrp_id
                and c.account_type = 'COBRA'
                and ep.reason_code = pr.reason_code
                and pr.reason_type = 'DISBURSEMENT'
                and exists (
                    select
                        *
                    from
                        ach_transfer
                    where
                            claim_id = ep.employer_payment_id
                        and transaction_type = 'D'
                        and acc_id = c.acc_id
                        and status = 3
                )
                and ep.cobra_disbursement_id = cp.cobra_payment_id
            union all
            select
                ep.entrp_id,
                'PAYMENT',
                - ep.check_amount,
                trunc(transaction_date),
                pr.reason_name,
                ep.note,
                ep.employer_payment_id,
                trunc(ep.creation_date) creation_date
            from
                employer_payments ep,
                account           c,
                pay_reason        pr,
                cobra_payments    cp
            where
                    ep.entrp_id = c.entrp_id
                and c.account_type = 'COBRA'
                and ep.reason_code = pr.reason_code
                and pr.reason_type = 'DISBURSEMENT'
                and pr.reason_code = 29
                and not exists (
                    select
                        *
                    from
                        ach_transfer
                    where
                        claim_id = ep.employer_payment_id
                )
                and ep.cobra_disbursement_id = cp.cobra_payment_id
  /*  UNION ALL
       SELECT ep.ENTRP_ID ,
      'PAYMENT' ,
      -EP.CHECK_AMOUNT ,
      trunc(TRANSACTION_DATE) ,
      pr.REASON_NAME ,
      EP.NOTE,
      ep.EMPLOYER_PAYMENT_ID,
      TRUNC(ep.creation_date) creation_date
    FROM employer_payments ep
    , ACCOUNT C
    , pay_reason pr
    , cobra_disbursements cp
    WHERE  Ep.ENTRP_ID = C.ENTRP_ID
    AND   C.ACCOUNT_TYPE  = 'COBRA'
    AND   EP.REASON_CODE = PR.REASON_CODE
    AND   PR.REASON_TYPE = 'DISBURSEMENT'
    AND EXISTS ( SELECT * FROM ACH_TRANSFER WHERE CLAIM_ID = EP.EMPLOYER_PAYMENT_ID AND TRANSACTION_TYPE = 'D' AND ACC_ID = C.ACC_ID AND STATUS = 3)
    AND   ep.cobra_disbursement_id = cp.cobra_disbursement_id*/
            union all
            select
                ep.entrp_id,
                'PAYMENT',
                - ep.check_amount,
                trunc(transaction_date),
                pr.reason_name,
                ep.note,
                ep.employer_payment_id,
                trunc(ep.creation_date) creation_date
            from
                employer_payments ep,
                account           c,
                pay_reason        pr,
                cobra_payments    cp,
                payment_register  preg
            where
                    ep.entrp_id = c.entrp_id
                and c.account_type = 'COBRA'
                and ep.cobra_disbursement_id = cp.cobra_payment_id
                and ep.payment_register_id = preg.payment_register_id
  --  AND PREG.CLAIM_TYPE IN ('COBRA_PAYMENTS', 'COBRA_DISBURSEMENT')
                and preg.claim_type in ( 'COBRA_PAYMENTS' )
                and ep.reason_code = pr.reason_code
                and pr.reason_type = 'DISBURSEMENT'
                and exists (
                    select
                        *
                    from
                        checks
                    where
                            entity_id = preg.payment_register_id
                        and entity_type = 'EMPLOYER_PAYMENTS'
                        and acc_id = c.acc_id
                        and status in ( 'SENT', 'MAILED' )
                )
        );


-- sqlcl_snapshot {"hash":"14d52910537b44a30698d7bd6edbe40390af9863","type":"VIEW","name":"COBRA_EMPLOYER_BALANCES_V","schemaName":"SAMQA","sxml":""}