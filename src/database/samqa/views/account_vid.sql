create or replace force editionable view samqa.account_vid (
    acc_id,
    pers_id,
    entrp_id,
    acc_num,
    plan_code,
    start_date,
    end_date,
    avid
) as
    (
        select
            acc_id,
            pers_id,
            entrp_id,
            acc_num,
            plan_code,
            start_date,
            end_date,
            decode(
                substr(acc_num, 1, 3),
                'CRB',
                1,
                0
            ) as avid -- CRB BANK
        from
            account
    );


-- sqlcl_snapshot {"hash":"00be14cd7d90df0af65f22e7af3b78a4d7a49a84","type":"VIEW","name":"ACCOUNT_VID","schemaName":"SAMQA","sxml":""}