comment on table samqa.payment1217 is
    'Business transaction, payment from the account';

comment on column samqa.payment1217.amount is
    'Total amount paid';

comment on column samqa.payment1217.change_num is
    'Account change number. Same sequence for Income and Payment';

comment on column samqa.payment1217.claim_id is
    'To which we pay';

comment on column samqa.payment1217.cur_bal is
    'Current balance';

comment on column samqa.payment1217.note is
    'Remarks';

comment on column samqa.payment1217.pay_date is
    'Date of payment';

comment on column samqa.payment1217.pay_num is
    'Cheque number, next value see ACCOUNT.LAST_PAY_NUM';

comment on column samqa.payment1217.reason_code is
    'Code reason of Payment';


-- sqlcl_snapshot {"hash":"6daae12ce62487adb0e543b6c89db675d394a3ec","type":"COMMENT","name":"payment1217","schemaName":"samqa","sxml":""}