-- liquibase formatted sql
-- changeset samqa:1754373926548 stripComments:false logicalFilePath:BASE_RELEASE\samqa\comments\claimn.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/comments/claimn.sql:null:e363ccbd9f63d436a35dddc82f5fdb5afd9ae649:create

comment on table samqa.claimn is
    'Claim, new table include details';

comment on column samqa.claimn.claim_code is
    'For example JOHN05022004';

comment on column samqa.claimn.claim_date_end is
    'Date of service to';

comment on column samqa.claimn.claim_date_start is
    'Date of service from';

comment on column samqa.claimn.claim_id is
    'Claim internal database code. For references to this record only';

comment on column samqa.claimn.claim_paid is
    'Amount of claim payment';

comment on column samqa.claimn.note is
    'Any useful remarks';

comment on column samqa.claimn.pers_id is
    'Reference to Subscriber, who pay this claim';

comment on column samqa.claimn.pers_patient is
    'Reference to person, who got service, Patient';

comment on column samqa.claimn.prov_name is
    'Provider of medical service';

comment on column samqa.claimn.service_status is
    'See EXPENSE_TYPE code table';

comment on column samqa.claimn.tax_code is
    'Code for taxation.';

