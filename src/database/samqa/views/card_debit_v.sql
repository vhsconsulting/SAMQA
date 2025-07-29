create or replace force editionable view samqa.card_debit_v (
    card_id,
    start_date,
    end_date,
    emitent,
    note,
    status,
    card_num,
    max_card_value,
    current_card_value,
    current_bal_value,
    current_auth_value,
    new_card_value,
    bal_adjust_value
) as
    (
        select
            card_id,
            start_date,
            end_date,
            emitent,
            note,
            status,
            card_num,
            max_card_value,
            current_card_value,
            current_bal_value,
            current_auth_value,
            new_card_value,
            bal_adjust_value
        from
            card_debit
    );


-- sqlcl_snapshot {"hash":"af7c6c58d65a60e0ee9ebe73099901c68f24cee0","type":"VIEW","name":"CARD_DEBIT_V","schemaName":"SAMQA","sxml":""}