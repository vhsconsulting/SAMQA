-- liquibase formatted sql
-- changeset SAMQA:1754374147954 stripComments:false logicalFilePath:BASE_RELEASE\samqa\sequences\cnb_check_seq.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/sequences/cnb_check_seq.sql:null:b1a12f5bc2fa85d28ea659f1208b1bb6f7035a4b:create

create sequence samqa.cnb_check_seq minvalue 1 maxvalue 9999999999999999999999999999 increment by 1 start with 17854 cache 20 noorder
nocycle nokeep noscale global;

