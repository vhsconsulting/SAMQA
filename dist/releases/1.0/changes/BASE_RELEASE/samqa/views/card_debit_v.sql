-- liquibase formatted sql
-- changeset SAMQA:1754374169595 stripComments:false logicalFilePath:BASE_RELEASE\samqa\views\card_debit_v.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/views/card_debit_v.sql:null:af7c6c58d65a60e0ee9ebe73099901c68f24cee0:create

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

