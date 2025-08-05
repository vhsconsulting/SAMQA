-- liquibase formatted sql
-- changeset samqa:1754373926531 stripComments:false logicalFilePath:BASE_RELEASE\samqa\comments\claim_detail.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/comments/claim_detail.sql:null:c47d5cd6f11a6972c4014f15c0b2527bb0ea9779:create

comment on table samqa.claim_detail is
    'Contents of claim';

comment on column samqa.claim_detail.claim_id is
    'Reference to CLAIM';

comment on column samqa.claim_detail.note is
    'Any useful remarks';

comment on column samqa.claim_detail.service_code is
    'Code by CPT';

comment on column samqa.claim_detail.service_count is
    'Number of units, default = 1';

comment on column samqa.claim_detail.service_name is
    'According service_code';

comment on column samqa.claim_detail.service_price is
    'Amount billed per unit';

comment on column samqa.claim_detail.service_status is
    'See EXPENSE_TYPE code table';

comment on column samqa.claim_detail.sure_amount is
    'Allowed amount of payment for this service, may not equal to SERVICE_PRICE';

comment on column samqa.claim_detail.tax_code is
    'Code for taxation. May be derive from SERVICE_CODE';

