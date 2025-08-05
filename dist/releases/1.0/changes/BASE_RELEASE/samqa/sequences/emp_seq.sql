-- liquibase formatted sql
-- changeset SAMQA:1754374148435 stripComments:false logicalFilePath:BASE_RELEASE\samqa\sequences\emp_seq.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/sequences/emp_seq.sql:null:338f821a7f8c9f08f74a5842ced7f8cc78e0cb1c:create

create sequence samqa.emp_seq minvalue 1 maxvalue 9999999999999999999999999999 increment by 1 start with 8000 cache 20 noorder nocycle
nokeep noscale global;

