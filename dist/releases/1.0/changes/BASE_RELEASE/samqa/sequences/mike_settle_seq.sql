-- liquibase formatted sql
-- changeset SAMQA:1754374149357 stripComments:false logicalFilePath:BASE_RELEASE\samqa\sequences\mike_settle_seq.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/sequences/mike_settle_seq.sql:null:ed5ea65a5fa6560830cd9ea4cf4e8e7f4f7030a1:create

create sequence samqa.mike_settle_seq minvalue 10001 maxvalue 1000000000000000000000000000 increment by 1 start with 14837 nocache noorder
nocycle nokeep noscale global;

