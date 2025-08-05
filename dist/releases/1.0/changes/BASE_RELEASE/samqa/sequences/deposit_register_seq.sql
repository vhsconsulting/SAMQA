-- liquibase formatted sql
-- changeset SAMQA:1754374148337 stripComments:false logicalFilePath:BASE_RELEASE\samqa\sequences\deposit_register_seq.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/sequences/deposit_register_seq.sql:null:72a6bdbae77219304efaf7b3b56446dd415814d1:create

create sequence samqa.deposit_register_seq minvalue 1 maxvalue 999999999999999999999999999 increment by 1 start with 12283136 cache 20
noorder nocycle nokeep noscale global;

