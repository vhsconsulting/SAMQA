-- liquibase formatted sql
-- changeset SAMQA:1753779760442 stripComments:false logicalFilePath:BASE_RELEASE\samqa\sequences\acc_seq.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/sequences/acc_seq.sql:null:47aab7ed561cf898ccc97204b72118c5da8dd435:create

create sequence samqa.acc_seq minvalue 1001 maxvalue 999999999 increment by 1 start with 1071252 nocache noorder nocycle nokeep noscale
global;

