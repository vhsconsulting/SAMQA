-- liquibase formatted sql
-- changeset SAMQA:1754374148312 stripComments:false logicalFilePath:BASE_RELEASE\samqa\sequences\demo_users_seq.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/sequences/demo_users_seq.sql:null:d0fc1826cfa2c91fe09cc680203831c3637079a9:create

create sequence samqa.demo_users_seq minvalue 1 maxvalue 999999999999999999999999999 increment by 1 start with 81 cache 20 noorder nocycle
nokeep noscale global;

