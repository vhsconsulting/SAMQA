-- liquibase formatted sql
-- changeset SAMQA:1754374147853 stripComments:false logicalFilePath:BASE_RELEASE\samqa\sequences\checks_batch_seq.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/sequences/checks_batch_seq.sql:null:310c9523929093c376cd6cc6627c9865500475d4:create

create sequence samqa.checks_batch_seq minvalue 1 maxvalue 9999999999999999999999999999 increment by 1 start with 330650 cache 20 noorder
nocycle nokeep noscale global;

