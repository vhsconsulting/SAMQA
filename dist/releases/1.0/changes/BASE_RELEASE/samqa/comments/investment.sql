-- liquibase formatted sql
-- changeset samqa:1754373926643 stripComments:false logicalFilePath:BASE_RELEASE\samqa\comments\investment.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/comments/investment.sql:null:435827e793971b54eac2228a75e327ed28aafc63:create

comment on table samqa.investment is
    'Outside Investments';

comment on column samqa.investment.acc_id is
    'Account ID in Sterling';

comment on column samqa.investment.end_date is
    'If not null, means account is closed';

comment on column samqa.investment.investment_id is
    'Primary key';

comment on column samqa.investment.invest_acc is
    'Account number of our subscriber in investment company';

comment on column samqa.investment.invest_id is
    'Investment (stockbroker) company';

comment on column samqa.investment.note is
    'Any useful remarks';

comment on column samqa.investment.start_date is
    'Date open the account';

