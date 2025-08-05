-- liquibase formatted sql
-- changeset samqa:1754373926566 stripComments:false logicalFilePath:BASE_RELEASE\samqa\comments\debit_card_updates.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/comments/debit_card_updates.sql:null:ba51141df4a9fcb42ffc7f40b4e7da109fced1cd:create

comment on table samqa.debit_card_updates is
    'Table to track updates to PERSON records for transmittal to Evolution Benefits. Populated by AFTER UPDATE trigger.';

comment on column samqa.debit_card_updates.acc_num is
    'Subscriber Account Number';

comment on column samqa.debit_card_updates.acc_num_changed is
    'Social Security Number Changed - Y/N';

comment on column samqa.debit_card_updates.acc_num_processed is
    'SSN Change Submitted to Evolution Benefits Y/N';

comment on column samqa.debit_card_updates.address is
    'Mailing Address';

comment on column samqa.debit_card_updates.city is
    'City';

comment on column samqa.debit_card_updates.date_changed is
    'Date and Time of data change';

comment on column samqa.debit_card_updates.demo_changed is
    'Demographics Changed - Y/N';

comment on column samqa.debit_card_updates.demo_processed is
    'Demographics Change Submitted to Evolution Benefits Y/N';

comment on column samqa.debit_card_updates.first_name is
    'First Name';

comment on column samqa.debit_card_updates.last_name is
    'Last Name';

comment on column samqa.debit_card_updates.middle_name is
    'Middle Initial';

comment on column samqa.debit_card_updates.pers_id is
    'Person Next Number';

comment on column samqa.debit_card_updates.ssn_newval is
    'SSN - New Social Security Number';

comment on column samqa.debit_card_updates.ssn_oldval is
    'SSN - Old Social Security Number';

comment on column samqa.debit_card_updates.state is
    'State';

comment on column samqa.debit_card_updates.update_id is
    'Update/Change Next Number';

comment on column samqa.debit_card_updates.zip is
    'Zip Code';

