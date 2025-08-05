-- liquibase formatted sql
-- changeset SAMQA:1754374148658 stripComments:false logicalFilePath:BASE_RELEASE\samqa\sequences\erisa_aca_seq.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/sequences/erisa_aca_seq.sql:null:f5bb854da398e328395026c3b6716b0b1e95b685:create

create sequence samqa.erisa_aca_seq minvalue 1 maxvalue 9999999999999999999999999999 increment by 1 start with 23465 cache 20 noorder
nocycle nokeep noscale global;

