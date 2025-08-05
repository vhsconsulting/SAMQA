-- liquibase formatted sql
-- changeset SAMQA:1754374149055 stripComments:false logicalFilePath:BASE_RELEASE\samqa\sequences\invoice_batch_seq.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/sequences/invoice_batch_seq.sql:null:bd22236c0fd747c664076fd1c6bcdf7f31a9f74e:create

create sequence samqa.invoice_batch_seq minvalue 1 maxvalue 999999999999999999999999999 increment by 1 start with 509739 cache 20 noorder
nocycle nokeep noscale global;

