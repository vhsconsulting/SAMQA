-- liquibase formatted sql
-- changeset SAMQA:1753779760615 stripComments:false logicalFilePath:BASE_RELEASE\samqa\sequences\ar_invoice_lines_seq.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/sequences/ar_invoice_lines_seq.sql:null:9fa35c68b9a289820b8ddab7f3c277bc6c49d43e:create

create sequence samqa.ar_invoice_lines_seq minvalue 1 maxvalue 999999999999999999999999999 increment by 1 start with 1220688 cache 20
noorder nocycle nokeep noscale global;

