-- liquibase formatted sql
-- changeset SAMQA:1754374149102 stripComments:false logicalFilePath:BASE_RELEASE\samqa\sequences\invoice_upload_id_seq.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/sequences/invoice_upload_id_seq.sql:null:307359df76d28415e8d85cfe7de30ff2a89703ea:create

create sequence samqa.invoice_upload_id_seq minvalue 1 maxvalue 9999999999999999999999999999 increment by 1 start with 3827 cache 20 noorder
nocycle nokeep noscale global;

