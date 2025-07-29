-- liquibase formatted sql
-- changeset SAMQA:1753779762174 stripComments:false logicalFilePath:BASE_RELEASE\samqa\sequences\invoice_parameters_seq.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/sequences/invoice_parameters_seq.sql:null:96fb327f38921b71b7087274abb107dc5bf6f73b:create

create sequence samqa.invoice_parameters_seq minvalue 1 maxvalue 999999999999999999999999999 increment by 1 start with 137814 cache 20
noorder nocycle nokeep noscale global;

