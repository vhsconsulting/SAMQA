-- liquibase formatted sql
-- changeset SAMQA:1754374149660 stripComments:false logicalFilePath:BASE_RELEASE\samqa\sequences\payment_acc_info_seq.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/sequences/payment_acc_info_seq.sql:null:092d140e9767f78240ffb6d9e07f76e6553d8377:create

create sequence samqa.payment_acc_info_seq minvalue 1 maxvalue 999999999999999999999999999 increment by 1 start with 41 cache 20 noorder
nocycle nokeep noscale global;

