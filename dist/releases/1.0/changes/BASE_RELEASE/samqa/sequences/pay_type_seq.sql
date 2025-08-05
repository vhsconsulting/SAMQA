-- liquibase formatted sql
-- changeset SAMQA:1754374149647 stripComments:false logicalFilePath:BASE_RELEASE\samqa\sequences\pay_type_seq.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/sequences/pay_type_seq.sql:null:fef15d6945a5eee90b1be9adfec6adfa09e6e525:create

create sequence samqa.pay_type_seq minvalue 1 maxvalue 999999999999999999999999999 increment by 1 start with 47 cache 20 noorder nocycle
nokeep noscale global;

