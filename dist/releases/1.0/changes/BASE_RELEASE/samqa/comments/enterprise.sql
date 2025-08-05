-- liquibase formatted sql
-- changeset samqa:1754373926592 stripComments:false logicalFilePath:BASE_RELEASE\samqa\comments\enterprise.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/comments/enterprise.sql:null:7de61ced9f97231af4c039fac92796ea00983950:create

comment on table samqa.enterprise is
    'All enterprises our interest: Employers, Banks, Insurance companies, Providers (hospital or doctor)';

comment on column samqa.enterprise.address is
    'Street, house etc.';

comment on column samqa.enterprise.card_allowed is
    'Debit cards for all the Subscribers in this Employer group: 0 = allowed, 1 = not allowed.';

comment on column samqa.enterprise.city is
    'city';

comment on column samqa.enterprise.entrp_code is
    'Tax Id or EIN  of enterprise';

comment on column samqa.enterprise.entrp_contact is
    'Who is your contact in that office.';

comment on column samqa.enterprise.entrp_email is
    'Enterprise e-mail address';

comment on column samqa.enterprise.entrp_id is
    'Enterprise internal database code.';

comment on column samqa.enterprise.entrp_main is
    'Reference to headquarters';

comment on column samqa.enterprise.entrp_pay is
    'Employer monthly contribution (same for all employees)';

comment on column samqa.enterprise.entrp_phones is
    'Enterprise phone numbers.';

comment on column samqa.enterprise.en_code is
    'Type of enterprise, see EN_TYPE Code Table';

comment on column samqa.enterprise.name is
    'Name of enterprise';

comment on column samqa.enterprise.note is
    'Any useful remarks';

comment on column samqa.enterprise.state is
    'State';

comment on column samqa.enterprise.zip is
    'Post index';

