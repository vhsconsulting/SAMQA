-- liquibase formatted sql
-- changeset SAMQA:1753779760639 stripComments:false logicalFilePath:BASE_RELEASE\samqa\sequences\ar_invoice_seq.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/sequences/ar_invoice_seq.sql:null:6da8da050b2f43b607c925e2c657147ef4fb3329:create

create sequence samqa.ar_invoice_seq minvalue 1 maxvalue 999999999999999999999999999 increment by 1 start with 857230 cache 20 noorder
nocycle nokeep noscale global;

