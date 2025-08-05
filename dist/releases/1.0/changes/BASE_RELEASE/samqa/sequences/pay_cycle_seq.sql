-- liquibase formatted sql
-- changeset SAMQA:1754374149612 stripComments:false logicalFilePath:BASE_RELEASE\samqa\sequences\pay_cycle_seq.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/sequences/pay_cycle_seq.sql:null:e5ebc524f555347d4136bf299897a0415525f9ff:create

create sequence samqa.pay_cycle_seq minvalue 1 maxvalue 9999999999999999999999999999 increment by 1 start with 17007 cache 20 noorder
nocycle nokeep noscale global;

