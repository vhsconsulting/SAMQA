-- liquibase formatted sql
-- changeset SAMQA:1753779762138 stripComments:false logicalFilePath:BASE_RELEASE\samqa\sequences\invoice_batch_seq.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/sequences/invoice_batch_seq.sql:null:0013bc30b5d42f1037de3d14e69fd1571864e9b5:create

create sequence samqa.invoice_batch_seq minvalue 1 maxvalue 999999999999999999999999999 increment by 1 start with 509679 cache 20 noorder
nocycle nokeep noscale global;

