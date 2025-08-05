-- liquibase formatted sql
-- changeset SAMQA:1754374157626 stripComments:false logicalFilePath:BASE_RELEASE\samqa\tables\eob_eligible_staging.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/tables/eob_eligible_staging.sql:null:ad63e11555356de6db14cb249a21b748588bc394:create

create table samqa.eob_eligible_staging (
    eligible_upload_id number,
    account_no         varchar2(100 byte),
    member_id          varchar2(100 byte),
    ssn                varchar2(20 byte),
    emp_last_name      varchar2(255 byte),
    emp_first_name     varchar2(255 byte),
    emp_dob            date,
    pers_id            number(9, 0),
    process_status     varchar2(20 byte),
    err_msg            varchar2(3200 byte),
    process_date       date
);

