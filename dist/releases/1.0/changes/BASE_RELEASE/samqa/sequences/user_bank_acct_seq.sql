-- liquibase formatted sql
-- changeset SAMQA:1754374150248 stripComments:false logicalFilePath:BASE_RELEASE\samqa\sequences\user_bank_acct_seq.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/sequences/user_bank_acct_seq.sql:null:881fe436531718c4297557a567c475ad10e2c4f3:create

create sequence samqa.user_bank_acct_seq minvalue 1 maxvalue 999999999999999999999999999 increment by 1 start with 484944 cache 20 noorder
nocycle nokeep noscale global;

