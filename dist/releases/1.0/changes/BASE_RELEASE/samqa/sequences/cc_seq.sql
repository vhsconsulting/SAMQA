-- liquibase formatted sql
-- changeset SAMQA:1754374147789 stripComments:false logicalFilePath:BASE_RELEASE\samqa\sequences\cc_seq.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/sequences/cc_seq.sql:null:daab51746f4f52b1d383f2e75ab976c15a9ae44a:create

create sequence samqa.cc_seq minvalue 1 maxvalue 999999999999999999999999999 increment by 1 start with 41 cache 20 noorder nocycle nokeep
noscale global;

