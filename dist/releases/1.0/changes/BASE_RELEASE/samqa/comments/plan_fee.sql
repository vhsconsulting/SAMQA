-- liquibase formatted sql
-- changeset samqa:1754373926757 stripComments:false logicalFilePath:BASE_RELEASE\samqa\comments\plan_fee.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/comments/plan_fee.sql:null:cc00e8143ec60ce83e7e20594d947da5c3abfb99:create

comment on table samqa.plan_fee is
    'Sterling HSA Fee Schedule and Type of Contributions.';

comment on column samqa.plan_fee.fee_amount is
    'Amount of fee';

comment on column samqa.plan_fee.fee_code is
    'For references only';

comment on column samqa.plan_fee.fee_name is
    'Name of fee';

comment on column samqa.plan_fee.note is
    'Remarks';

comment on column samqa.plan_fee.plan_code is
    'For references only';

