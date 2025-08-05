-- liquibase formatted sql
-- changeset samqa:1754373926497 stripComments:false logicalFilePath:BASE_RELEASE\samqa\comments\card_transfer.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/comments/card_transfer.sql:null:c677dc05b64521e160ae3a946a8df859ce581482:create

comment on table samqa.card_transfer is
    'Transfers to Debit card';

comment on column samqa.card_transfer.card_id is
    'Reference to Card holder';

comment on column samqa.card_transfer.cur_bal is
    'Current balance';

comment on column samqa.card_transfer.note is
    'Any useful remarks';

comment on column samqa.card_transfer.transfer_amount is
    'Transfer amount';

comment on column samqa.card_transfer.transfer_date is
    'Transfer date';

comment on column samqa.card_transfer.transfer_id is
    'Primary key';

