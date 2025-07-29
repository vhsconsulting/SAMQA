-- liquibase formatted sql
-- changeset SAMQA:1753779762149 stripComments:false logicalFilePath:BASE_RELEASE\samqa\sequences\invoice_number_seq.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/sequences/invoice_number_seq.sql:null:2a794a4e3d3d628de1366fc8b434f898e6848821:create

create sequence samqa.invoice_number_seq minvalue 1 maxvalue 999999999999999999999999999 increment by 1 start with 816990 cache 20 noorder
nocycle nokeep noscale global;

