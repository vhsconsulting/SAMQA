-- liquibase formatted sql
-- changeset SAMQA:1754374149635 stripComments:false logicalFilePath:BASE_RELEASE\samqa\sequences\pay_reason_seq.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/sequences/pay_reason_seq.sql:null:1aad628f34de6bb15f4dfb85c83d1f2134ca15ed:create

create sequence samqa.pay_reason_seq minvalue 1 maxvalue 999999999999999999999999999 increment by 1 start with 280 cache 20 noorder nocycle
nokeep noscale global;

