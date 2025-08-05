-- liquibase formatted sql
-- changeset SAMQA:1754374147665 stripComments:false logicalFilePath:BASE_RELEASE\samqa\sequences\benefit_code_seq.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/sequences/benefit_code_seq.sql:null:f0e2d5192aefb1b1cce59b7ccfbcc1b4caab5a92:create

create sequence samqa.benefit_code_seq minvalue 1 maxvalue 9999999999999999999999999999 increment by 1 start with 361357 cache 20 noorder
nocycle nokeep noscale global;

