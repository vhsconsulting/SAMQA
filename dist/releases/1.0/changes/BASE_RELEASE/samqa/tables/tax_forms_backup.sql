-- liquibase formatted sql
-- changeset SAMQA:1754374163630 stripComments:false logicalFilePath:BASE_RELEASE\samqa\tables\tax_forms_backup.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/tables/tax_forms_backup.sql:null:cf067281ccfc4f94472ea369f1d786490df85042:create

create table samqa.tax_forms_backup (
    tax_form_id     number,
    batch_number    number,
    acc_id          number,
    pers_id         number,
    acc_num         varchar2(30 byte),
    start_date      date,
    start_fee_date  date,
    begin_date      date,
    end_date        date,
    prev_yr_deposit number,
    curr_yr_deposit number,
    rollover        number,
    current_bal     number,
    gross_dist      number,
    creation_date   date,
    tax_doc_type    varchar2(30 byte)
);

