create or replace force editionable view samqa.teamster_v (
    acc_num,
    acc_id,
    entrp_id,
    fee_setup,
    fee_maint
) as
    select
        a.acc_num,
        a.acc_id,
        a.entrp_id,
        fee_setup,
        fee_maint
    from
        account            a,
        account_preference b
    where
            a.acc_id = b.acc_id
        and b.teamster_group = 'Y'
    order by
        1;


-- sqlcl_snapshot {"hash":"587b050396f3e05353bba7c0136e4d92993150d7","type":"VIEW","name":"TEAMSTER_V","schemaName":"SAMQA","sxml":""}