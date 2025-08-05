-- liquibase formatted sql
-- changeset SAMQA:1754374148813 stripComments:false logicalFilePath:BASE_RELEASE\samqa\sequences\file_seq.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/sequences/file_seq.sql:null:d9e83d45759d7dffe4caa6d1db1cfac3381c4792:create

create sequence samqa.file_seq minvalue 1 maxvalue 999999999999999999999999999 increment by 1 start with 6800733 cache 20 noorder nocycle
nokeep noscale global;

