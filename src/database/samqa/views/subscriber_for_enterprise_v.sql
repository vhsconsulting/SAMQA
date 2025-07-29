create or replace force editionable view samqa.subscriber_for_enterprise_v (
    acc_id,
    pers_id,
    entrp_id,
    entrp_acc_id
) as
    select
        d.acc_id,
        b.pers_id,
        a.entrp_id,
        c.acc_id entrp_acc_id
    from
        enterprise a,
        person     b,
        account    c,
        account    d
    where
            a.entrp_id = c.entrp_id
        and a.entrp_id = b.entrp_id
        and b.pers_id = d.pers_id;


-- sqlcl_snapshot {"hash":"62be84e802e5d64d24f1134d26164fd3ecf39db9","type":"VIEW","name":"SUBSCRIBER_FOR_ENTERPRISE_V","schemaName":"SAMQA","sxml":""}