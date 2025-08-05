-- liquibase formatted sql
-- changeset SAMQA:1754374147553 stripComments:false logicalFilePath:BASE_RELEASE\samqa\sequences\ar_invoice_seq.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/sequences/ar_invoice_seq.sql:null:bd4da72b87bb8d581a55025e8a8c6433da0876f7:create

create sequence samqa.ar_invoice_seq minvalue 1 maxvalue 999999999999999999999999999 increment by 1 start with 857330 cache 20 noorder
nocycle nokeep noscale global;

