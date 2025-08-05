-- liquibase formatted sql
-- changeset samqa:1754373926487 stripComments:false logicalFilePath:BASE_RELEASE\samqa\comments\card_debit.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/comments/card_debit.sql:null:7bb56e0a7ec68c5c0efd3cd9becf95a969d7ed00:create

comment on table samqa.card_debit is
    'Debit card info';

comment on column samqa.card_debit.bal_adjust_value is
    'this is (CURRENT_CARD_VALUE - NEW_CARD_VALUE)';

comment on column samqa.card_debit.card_id is
    'Reference to Card holder';

comment on column samqa.card_debit.card_num is
    'card number';

comment on column samqa.card_debit.current_auth_value is
    'Sum of the transactoins in the current authorization file';

comment on column samqa.card_debit.current_bal_value is
    'current balance on the account';

comment on column samqa.card_debit.current_card_value is
    'current amount stored on the card with EB (we can audit with a balance file)';

comment on column samqa.card_debit.emitent is
    'The Card emitent, reference to ENTERPRISE';

comment on column samqa.card_debit.end_date is
    'Card close or suspend date';

comment on column samqa.card_debit.max_card_value is
    'The MAX LIMIT for the card, DEFAULT $500, but could be raised if the account holder requests and there is balance available';

comment on column samqa.card_debit.new_card_value is
    'New calculated value that the card should be: LEAST(MAX_CARD_VALUE, (CURRENT_BAL_VALUE - CURRENT_AUTH_VALUE - 50) WHERE CURRENT_BAL_VALUE > 50'
    ;

comment on column samqa.card_debit.note is
    'Any useful remarks';

comment on column samqa.card_debit.start_date is
    'Card open or reguest date - see status';

comment on column samqa.card_debit.status is
    'status of a debit card, see cards_v';

