-- liquibase formatted sql
-- changeset SAMQA:1754374149836 stripComments:false logicalFilePath:BASE_RELEASE\samqa\sequences\receipt_id_seq.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/sequences/receipt_id_seq.sql:null:70db9331d303161538a54d696ec9adb9c101795d:create

create sequence samqa.receipt_id_seq minvalue 1 maxvalue 999999999999999999999999999 increment by 1 start with 8134 cache 20 noorder nocycle
nokeep noscale global;

