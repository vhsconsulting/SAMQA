-- liquibase formatted sql
-- changeset SAMQA:1754374147350 stripComments:false logicalFilePath:BASE_RELEASE\samqa\sequences\acc_seq.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/sequences/acc_seq.sql:null:e6bd9468a0b2ec1de0847f60432a35c94a240a1d:create

create sequence samqa.acc_seq minvalue 1001 maxvalue 999999999 increment by 1 start with 1071289 nocache noorder nocycle nokeep noscale
global;

