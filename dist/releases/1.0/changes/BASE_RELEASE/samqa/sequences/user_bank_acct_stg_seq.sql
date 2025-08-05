-- liquibase formatted sql
-- changeset SAMQA:1754374150261 stripComments:false logicalFilePath:BASE_RELEASE\samqa\sequences\user_bank_acct_stg_seq.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/sequences/user_bank_acct_stg_seq.sql:null:77396d1b015fdd114b30ac01e4bc3390238f7a07:create

create sequence samqa.user_bank_acct_stg_seq minvalue 1 maxvalue 9999999999999999999999999999 increment by 1 start with 16447 cache 20
noorder nocycle nokeep noscale global;

