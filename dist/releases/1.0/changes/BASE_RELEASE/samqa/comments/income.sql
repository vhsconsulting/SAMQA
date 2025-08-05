-- liquibase formatted sql
-- changeset samqa:1754373926614 stripComments:false logicalFilePath:BASE_RELEASE\samqa\comments\income.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/comments/income.sql:null:6cd64eb04e084494a364cdfad0e70c7708f594d3:create

comment on table samqa.income is
    'Contributions to the account';

comment on column samqa.income.amount is
    'Amount of contribution';

comment on column samqa.income.amount_add is
    'Additional amount. For example, subscriber add to his employer payment';

comment on column samqa.income.cc_code is
    'Credit card type, see CC_TYPE code tables';

comment on column samqa.income.cc_date is
    'Expiration date';

comment on column samqa.income.cc_number is
    'Credit card or Cheque number';

comment on column samqa.income.cc_owner is
    'Name on Credit Card';

comment on column samqa.income.change_num is
    'Account change number. Same sequence for Income and Payment';

comment on column samqa.income.contributor is
    'NULL means the subscriber. Else = employer code';

comment on column samqa.income.cur_bal is
    'Current balance';

comment on column samqa.income.fee_code is
    'Code reason of contribution';

comment on column samqa.income.fee_date is
    'Date of contribution';

comment on column samqa.income.note is
    'Any additional info, for example "Transfer from old account."';

comment on column samqa.income.pay_code is
    'Way of pay, see PAY_TYPE code tables';

