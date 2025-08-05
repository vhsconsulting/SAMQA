-- liquibase formatted sql
-- changeset SAMQA:1754374148249 stripComments:false logicalFilePath:BASE_RELEASE\samqa\sequences\demo_cust_seq.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/sequences/demo_cust_seq.sql:null:fed9d78364d0d4a1057a978d468611593d49c4ea:create

create sequence samqa.demo_cust_seq minvalue 1 maxvalue 999999999999999999999999999 increment by 1 start with 41 cache 20 noorder nocycle
nokeep noscale global;

