-- liquibase formatted sql
-- changeset samqa:1754373926516 stripComments:false logicalFilePath:BASE_RELEASE\samqa\comments\claim.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/comments/claim.sql:null:bb976966c78936a23f7cd34c38de659eecbfd9d7:create

comment on table samqa.claim is
    'Claim or bill';

comment on column samqa.claim.bill_val is
    'Amount of bill payment, positive for bill only';

comment on column samqa.claim.claim_bill is
    'Amount billed';

comment on column samqa.claim.claim_code is
    'For example JOHN05022004';

comment on column samqa.claim.claim_date_end is
    'Date of service to';

comment on column samqa.claim.claim_date_start is
    'Date of service from';

comment on column samqa.claim.claim_id is
    'For references to this record only';

comment on column samqa.claim.claim_paid is
    'Amount of bill payment';

comment on column samqa.claim.note is
    'Any useful remarks';

comment on column samqa.claim.pers_id is
    'Reference to person, who got service';

comment on column samqa.claim.pers_patient is
    'Patient person Code';

comment on column samqa.claim.prov_id is
    'Provider of medical service';

comment on column samqa.claim.receive_date is
    'When claim received from Insurers';

comment on column samqa.claim.remainder is
    'Unpaid remainder of claim or bill amount';

comment on column samqa.claim.send_date is
    'When claim sent to Insurers';

comment on column samqa.claim.service_doctor is
    'Doctor''s name';

