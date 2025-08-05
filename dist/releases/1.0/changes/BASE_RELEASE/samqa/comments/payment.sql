-- liquibase formatted sql
-- changeset samqa:1754373926678 stripComments:false logicalFilePath:BASE_RELEASE\samqa\comments\payment.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/comments/payment.sql:null:36ea79420723a0d2fe6496e8bf895f5c8c2df62f:create

comment on table samqa.payment is
    'Business transaction, payment from the account';

comment on column samqa.payment.amount is
    'Total amount paid';

comment on column samqa.payment.change_num is
    'Account change number. Same sequence for Income and Payment';

comment on column samqa.payment.claim_id is
    'To which we pay';

comment on column samqa.payment.cur_bal is
    'Current balance';

comment on column samqa.payment.note is
    'Remarks';

comment on column samqa.payment.pay_date is
    'Date of payment';

comment on column samqa.payment.pay_num is
    'Cheque number, next value see ACCOUNT.LAST_PAY_NUM';

comment on column samqa.payment.reason_code is
    'Code reason of Payment';

