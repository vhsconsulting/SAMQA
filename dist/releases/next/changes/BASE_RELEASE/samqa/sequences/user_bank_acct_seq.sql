-- liquibase formatted sql
-- changeset SAMQA:1753779763308 stripComments:false logicalFilePath:BASE_RELEASE\samqa\sequences\user_bank_acct_seq.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/sequences/user_bank_acct_seq.sql:null:d6889d6ce73d70393e81126589943194c5da7d22:create

create sequence samqa.user_bank_acct_seq minvalue 1 maxvalue 999999999999999999999999999 increment by 1 start with 484864 cache 20 noorder
nocycle nokeep noscale global;

