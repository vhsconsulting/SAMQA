-- liquibase formatted sql
-- changeset SAMQA:1754374169659 stripComments:false logicalFilePath:BASE_RELEASE\samqa\views\cards_v.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/views/cards_v.sql:null:a01e73650e95040041b954b11016b979c8e826b6:create

create or replace force editionable view samqa.cards_v (
    lookup_name,
    stat,
    nstat,
    note
) as
    select
        lookup_name,
        lookup_code stat,
        meaning     nstat,
        description note
    from
        lookups
    where
        lookup_name = 'DEBIT_CARD_STATUS';

