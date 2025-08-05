-- liquibase formatted sql
-- changeset SAMQA:1754374150133 stripComments:false logicalFilePath:BASE_RELEASE\samqa\sequences\settlement_seq.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/sequences/settlement_seq.sql:null:54e59da2ce71c5ad0643e27b5080a117321b085f:create

create sequence samqa.settlement_seq minvalue 10001 maxvalue 1000000000000000000000000000 increment by 1 start with 1340417 nocache noorder
nocycle nokeep noscale global;

