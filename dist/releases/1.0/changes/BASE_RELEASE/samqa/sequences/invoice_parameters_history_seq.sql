-- liquibase formatted sql
-- changeset SAMQA:1754374149070 stripComments:false logicalFilePath:BASE_RELEASE\samqa\sequences\invoice_parameters_history_seq.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/sequences/invoice_parameters_history_seq.sql:null:10fadd76c359c9cb04162b2ee251823ffc1dd79c:create

create sequence samqa.invoice_parameters_history_seq minvalue 1 maxvalue 9999999999999999999999999999 increment by 1 start with 21634
cache 20 noorder nocycle nokeep noscale global;

