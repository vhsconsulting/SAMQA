-- liquibase formatted sql
-- changeset SAMQA:1754374162127 stripComments:false logicalFilePath:BASE_RELEASE\samqa\tables\person.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/tables/person.sql:null:41f012e2c6a06edaa87f9e14ed8724e2dc052695:create

create table samqa.person (
    pers_id                   number(9, 0) not null enable,
    first_name                varchar2(255 byte),
    middle_name               varchar2(1 byte),
    last_name                 varchar2(50 byte) not null enable,
    birth_date                date,
    title                     varchar2(20 byte),
    gender                    varchar2(1 byte),
    ssn                       varchar2(20 byte),
    drivlic                   varchar2(50 byte),
    passport                  varchar2(50 byte),
    address                   varchar2(100 byte),
    city                      varchar2(100 byte),
    state                     varchar2(2 byte) default 'CA',
    zip                       varchar2(10 byte),
    county                    varchar2(20 byte),
    pobox                     varchar2(20 byte),
    mailmet                   number(3, 0),
    phone_day                 varchar2(100 byte),
    phone_even                varchar2(100 byte),
    email                     varchar2(100 byte),
    pers_main                 number(9, 0),
    relat_code                number(3, 0),
    ben_code                  varchar2(1 byte),
    ben_rate                  number(3, 0),
    password                  varchar2(20 byte),
    note                      varchar2(4000 byte),
    entrp_id                  number(9, 0),
    profession                varchar2(20 byte),
    acc_numc                  varchar2(20 byte),
    mass_enrollment_id        number,
    person_type               varchar2(30 byte),
    creation_date             date default sysdate,
    created_by                number default - 1,
    last_update_date          date default sysdate,
    last_updated_by           number default - 1,
    card_issue_flag           varchar2(1 byte),
    pers_start_date           date,
    pers_end_date             date,
    orig_sys_vendor_ref       varchar2(3200 byte),
    division_code             varchar2(30 byte),
    deceased_date             date,
    valid_address             varchar2(1 byte),
    address_verified          varchar2(1 byte),
    commissions_payable_to    varchar2(100 byte),
    phy_address_flag          varchar2(1 byte) default 'Y',
    address2                  varchar2(100 byte),
        masked_ssn                varchar2(11 byte) generated always as ( '***-**-'
                                                           || substr(ssn, 8, 4) ) virtual,
    waive_covr                varchar2(100 byte),
    hire_date                 date,
    use_family                varchar2(100 byte),
    send_general_right_letter varchar2(30 byte),
    employee_type             varchar2(255 byte),
    payroll_type              varchar2(255 byte),
        full_name                 varchar2(500 byte) generated always as ( first_name
                                                           || nvl(' ' || middle_name, '')
                                                           || ' '
                                                           || last_name ) virtual
);

create unique index samqa.pers_pk on
    samqa.person (
        pers_id
    );

alter table samqa.person
    add constraint person_ben_code
        check ( ben_code in ( 'P', 'C' ) ) enable;

alter table samqa.person
    add constraint person_ben_rate check ( ben_rate <= 100 ) enable;

alter table samqa.person
    add constraint person_gender
        check ( gender in ( 'M', 'F', 'O' ) ) enable;

alter table samqa.person
    add constraint pers_pk
        primary key ( pers_id )
            using index samqa.pers_pk enable;

