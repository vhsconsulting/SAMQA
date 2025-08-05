-- liquibase formatted sql
-- changeset SAMQA:1754374149623 stripComments:false logicalFilePath:BASE_RELEASE\samqa\sequences\pay_details_seq.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/sequences/pay_details_seq.sql:null:62ba3021bab189078f394bae432fec7853439f61:create

create sequence samqa.pay_details_seq minvalue 1 maxvalue 999999999999999999999999999 increment by 1 start with 182567 cache 20 noorder
nocycle nokeep noscale global;

