create or replace force editionable view samqa.card_debit_acc (
    acc_id,
    pers_id,
    card_id,
    start_date,
    end_date,
    emitent,
    note,
    status,
    card_num,
    max_card_value,
    current_card_value
) as
    (
        select
            a.acc_id,
            a.pers_id,
            c.card_id,
            c.start_date,
            c.end_date,
            c.emitent,
            c.note,
            c.status,
            c.card_num,
            c.max_card_value,
            c.current_card_value
        from
            card_debit c,
            person     p,
            account    a -- link card and account
        where
                c.card_id = p.pers_id -- card belong the person
            and ( a.pers_id = p.pers_id -- this person is account holder
                  or a.pers_id = p.pers_main ) -- or "main" person
    );


-- sqlcl_snapshot {"hash":"ea442869b9c82043844c9612fbb7fafdda899d28","type":"VIEW","name":"CARD_DEBIT_ACC","schemaName":"SAMQA","sxml":""}