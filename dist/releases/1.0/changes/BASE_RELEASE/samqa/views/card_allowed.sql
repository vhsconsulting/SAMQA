-- liquibase formatted sql
-- changeset SAMQA:1754374169563 stripComments:false logicalFilePath:BASE_RELEASE\samqa\views\card_allowed.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/views/card_allowed.sql:null:5a1ef4ff839c19a551a459ec83de58d58c59ed0a:create

create or replace force editionable view samqa.card_allowed (
    lookup_code,
    meaning
) as
    select
        lookup_code,
        meaning
    from
        lookups
    where
        lookup_name = 'CARD_ALLOWED';

