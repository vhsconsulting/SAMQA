-- liquibase formatted sql
-- changeset samqa:1754373926448 stripComments:false logicalFilePath:BASE_RELEASE\samqa\comments\account.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/comments/account.sql:null:31940058ca5e2e9265c18bead7d5b9c3d5c8a36f:create

comment on table samqa.account is
    'Health Saving Account';

comment on column samqa.account.acc_id is
    'Account internal database code.';

comment on column samqa.account.acc_num is
    'Trust account number of subscriber';

comment on column samqa.account.broker_id is
    'Broker of record';

comment on column samqa.account.broker_pay is
    'Commission payment to broker';

comment on column samqa.account.end_date is
    'If not null, means account is closed';

comment on column samqa.account.entrp_id is
    'Reference to Employer, Account owner. Null for individual account';

comment on column samqa.account.fee_ini is
    'Initial Contribution';

comment on column samqa.account.fee_maint is
    'First Two Months Maintenance Fee';

comment on column samqa.account.fee_setup is
    'Account Set-up Fee';

comment on column samqa.account.ga_id is
    'Date of change balance. No need broker fire data, use this field another way. :-)';

comment on column samqa.account.last_pay_num is
    'Last payment number = cheque counter for this Subscriber';

comment on column samqa.account.month_pay is
    'Monthly contribution';

comment on column samqa.account.note is
    'Any useful remarks';

comment on column samqa.account.pay_code is
    'Methods of payment, see PAY_TYPE';

comment on column samqa.account.pay_period is
    'Monthly, Quarterly, Annually...';

comment on column samqa.account.pers_id is
    'Reference to Subscriber, Account owner. Null for group account';

comment on column samqa.account.plan_code is
    'Reference to Sterling HSA Fee Schedule';

comment on column samqa.account.reg_date is
    'Date registration the account';

comment on column samqa.account.start_amount is
    'Year beginning balance';

comment on column samqa.account.start_date is
    'Date open the account';

