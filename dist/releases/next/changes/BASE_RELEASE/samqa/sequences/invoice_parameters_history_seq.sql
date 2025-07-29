-- liquibase formatted sql
-- changeset SAMQA:1753779762161 stripComments:false logicalFilePath:BASE_RELEASE\samqa\sequences\invoice_parameters_history_seq.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/sequences/invoice_parameters_history_seq.sql:null:045f993add0f5d0a2f917496d7a51595932def0e:create

create sequence samqa.invoice_parameters_history_seq minvalue 1 maxvalue 9999999999999999999999999999 increment by 1 start with 21594
cache 20 noorder nocycle nokeep noscale global;

