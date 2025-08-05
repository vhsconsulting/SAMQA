-- liquibase formatted sql
-- changeset SAMQA:1754374147541 stripComments:false logicalFilePath:BASE_RELEASE\samqa\sequences\ar_invoice_notif_seq.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/sequences/ar_invoice_notif_seq.sql:null:f24a52d57b40c8b6f47c8b2c9ed2083162efe301:create

create sequence samqa.ar_invoice_notif_seq minvalue 1 maxvalue 9999999999999999999999999999 increment by 1 start with 66743 cache 20 noorder
nocycle nokeep noscale global;

