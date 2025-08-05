-- liquibase formatted sql
-- changeset SAMQA:1754374147590 stripComments:false logicalFilePath:BASE_RELEASE\samqa\sequences\bank_rate_seq.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/sequences/bank_rate_seq.sql:null:0f3f3c0f8bde802b1f556ed7a81e7f3b0972c322:create

create sequence samqa.bank_rate_seq minvalue 1 maxvalue 999999999999999999999999999 increment by 1 start with 761 cache 20 noorder nocycle
nokeep noscale global;

