-- liquibase formatted sql
-- changeset SAMQA:1754374149070 stripComments:false logicalFilePath:BASE_RELEASE\samqa\sequences\invoice_number_seq.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/sequences/invoice_number_seq.sql:null:394e0c2e07efc8841e3c610770b7d24fd9819bd4:create

create sequence samqa.invoice_number_seq minvalue 1 maxvalue 999999999999999999999999999 increment by 1 start with 817090 cache 20 noorder
nocycle nokeep noscale global;

