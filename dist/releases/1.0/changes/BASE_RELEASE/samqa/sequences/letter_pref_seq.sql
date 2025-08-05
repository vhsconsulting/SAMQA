-- liquibase formatted sql
-- changeset SAMQA:1754374149150 stripComments:false logicalFilePath:BASE_RELEASE\samqa\sequences\letter_pref_seq.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/sequences/letter_pref_seq.sql:null:6e402aeb7078d1289b2c650f565f44e74206dda4:create

create sequence samqa.letter_pref_seq minvalue 1001 maxvalue 999999999 increment by 1 start with 1002 nocache noorder nocycle nokeep noscale
global;

