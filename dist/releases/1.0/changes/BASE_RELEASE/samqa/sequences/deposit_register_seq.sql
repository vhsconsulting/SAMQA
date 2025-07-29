-- liquibase formatted sql
-- changeset SAMQA:1753779761394 stripComments:false logicalFilePath:BASE_RELEASE\samqa\sequences\deposit_register_seq.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/sequences/deposit_register_seq.sql:null:0fdfb3fae21bbe422a7718b59dfd06c422f97e3d:create

create sequence samqa.deposit_register_seq minvalue 1 maxvalue 999999999999999999999999999 increment by 1 start with 12283116 cache 20
noorder nocycle nokeep noscale global;

