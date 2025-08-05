-- liquibase formatted sql
-- changeset SAMQA:1754374160185 stripComments:false logicalFilePath:BASE_RELEASE\samqa\tables\mass_enroll_dependant.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/tables/mass_enroll_dependant.sql:null:e7d4ad9095a2c4d6a8abc6eef062e5218dad78e9:create

create table samqa.mass_enroll_dependant (
    mass_enrollment_id   number,
    subscriber_ssn       varchar2(30 byte),
    first_name           varchar2(255 byte),
    middle_name          varchar2(255 byte),
    last_name            varchar2(255 byte),
    gender               varchar2(30 byte),
    birth_date           varchar2(30 byte),
    ssn                  varchar2(30 byte),
    relative             varchar2(30 byte),
    dep_flag             varchar2(30 byte),
    beneficiary_type     varchar2(30 byte),
    beneficiary_relation varchar2(30 byte),
    effective_date       varchar2(12 byte),
    distiribution        varchar2(30 byte),
    entrp_acc_id         number,
    error_message        varchar2(3200 byte),
    creation_date        date,
    created_by           varchar2(30 byte),
    last_update_date     date,
    last_updated_by      varchar2(30 byte),
    error_column         varchar2(30 byte),
    debit_card_flag      varchar2(1 byte),
    account_type         varchar2(30 byte),
    acc_num              varchar2(3200 byte),
    batch_number         number,
    error_value          varchar2(2500 byte)
);

create unique index samqa.mass_enroll_dependant_pk on
    samqa.mass_enroll_dependant (
        mass_enrollment_id
    );

alter table samqa.mass_enroll_dependant
    add constraint mass_enroll_dependant_pk
        primary key ( mass_enrollment_id )
            using index samqa.mass_enroll_dependant_pk enable;

