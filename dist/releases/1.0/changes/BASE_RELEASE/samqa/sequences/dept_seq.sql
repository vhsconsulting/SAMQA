-- liquibase formatted sql
-- changeset SAMQA:1754374148351 stripComments:false logicalFilePath:BASE_RELEASE\samqa\sequences\dept_seq.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/sequences/dept_seq.sql:null:f0e2a77c73f75e94db11d813f6caf37d5e165cfc:create

create sequence samqa.dept_seq minvalue 1 maxvalue 9999999999999999999999999999 increment by 1 start with 50 cache 20 noorder nocycle
nokeep noscale global;

