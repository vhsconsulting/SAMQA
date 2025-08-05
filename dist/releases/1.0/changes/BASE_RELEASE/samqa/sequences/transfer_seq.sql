-- liquibase formatted sql
-- changeset SAMQA:1754374150219 stripComments:false logicalFilePath:BASE_RELEASE\samqa\sequences\transfer_seq.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/sequences/transfer_seq.sql:null:7fb3c1e412c407a044121abec28c805a635eba02:create

create sequence samqa.transfer_seq minvalue 1 maxvalue 999999999 increment by 1 start with 105384 nocache noorder nocycle nokeep noscale
global;

