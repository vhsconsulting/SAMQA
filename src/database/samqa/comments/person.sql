comment on table samqa.person is
    'Key info about subscriber and dependants. Also about Beneficiaries, if Ben_code NOT NULL and about Brokers';

comment on column samqa.person.acc_numc is
    'Reverse Copy account number of subscriber';

comment on column samqa.person.address is
    'Mailing address';

comment on column samqa.person.ben_code is
    'Beneficiary code, Primary OR Contingent.';

comment on column samqa.person.ben_rate is
    'Beneficiary distribution percentage.';

comment on column samqa.person.birth_date is
    'Date of birth';

comment on column samqa.person.city is
    'City';

comment on column samqa.person.county is
    'County';

comment on column samqa.person.drivlic is
    'Driver licence.';

comment on column samqa.person.email is
    'e-mail home address';

comment on column samqa.person.entrp_id is
    'Subscriber Employer ID';

comment on column samqa.person.first_name is
    'First name';

comment on column samqa.person.gender is
    'M/F';

comment on column samqa.person.last_name is
    'Last name';

comment on column samqa.person.mailmet is
    'Preferred contact method';

comment on column samqa.person.middle_name is
    'Middle initial';

comment on column samqa.person.note is
    'Any useful remarks';

comment on column samqa.person.passport is
    'Passport Number.';

comment on column samqa.person.password is
    'For data access, coded';

comment on column samqa.person.pers_id is
    'Person''s internal database code.';

comment on column samqa.person.pers_main is
    'Reference to subscriber';

comment on column samqa.person.phone_day is
    'Day time phone number.';

comment on column samqa.person.phone_even is
    'Evening phone number.';

comment on column samqa.person.pobox is
    'PO box';

comment on column samqa.person.profession is
    'Profession, occupation';

comment on column samqa.person.relat_code is
    'See table relative';

comment on column samqa.person.ssn is
    'SSN - Social Security Number OR EIN - Taxpayer ID Number';

comment on column samqa.person.state is
    'State';

comment on column samqa.person.title is
    'For use in letters, Mr. or Ms. or Dr. etc.';

comment on column samqa.person.zip is
    'Post index';


-- sqlcl_snapshot {"hash":"e37e243178a964d011daa22b2f361f68b33db946","type":"COMMENT","name":"person","schemaName":"samqa","sxml":""}