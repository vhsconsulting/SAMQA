-- liquibase formatted sql
-- changeset samqa:1754373926668 stripComments:false logicalFilePath:BASE_RELEASE\samqa\comments\pay_reason.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/comments/pay_reason.sql:null:d3a81770d6bb3b9f8a6123b67b5d546647a34c8f:create

comment on table samqa.pay_reason is
    'Reasons of payment';

comment on column samqa.pay_reason.reason_code is
    'For references only';

comment on column samqa.pay_reason.reason_name is
    'Name of reason';

