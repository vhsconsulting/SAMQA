-- liquibase formatted sql
-- changeset SAMQA:1754374152372 stripComments:false logicalFilePath:BASE_RELEASE\samqa\tables\beneficiary.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/tables/beneficiary.sql:null:d64083796bebd82db01b41c888bad28933139fc8:create

create table samqa.beneficiary (
    beneficiary_id     number,
    beneficiary_name   varchar2(300 byte),
    beneficiary_type   number,
    relat_code         varchar2(30 byte),
    effective_date     date,
    pers_id            number,
    creation_date      date,
    created_by         number,
    distribution       number,
    note               varchar2(3200 byte),
    mass_enrollment_id number,
    effective_end_date date,
    last_updated_by    number,
    last_update_date   date
);

create unique index samqa.beneficiary_pk on
    samqa.beneficiary (
        beneficiary_id
    );

alter table samqa.beneficiary
    add constraint beneficiary_pk
        primary key ( beneficiary_id )
            using index samqa.beneficiary_pk enable;

