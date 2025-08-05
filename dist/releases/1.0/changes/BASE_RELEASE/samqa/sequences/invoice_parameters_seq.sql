-- liquibase formatted sql
-- changeset SAMQA:1754374149086 stripComments:false logicalFilePath:BASE_RELEASE\samqa\sequences\invoice_parameters_seq.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/sequences/invoice_parameters_seq.sql:null:99f027040fb03cd3342adbe2ce942d3deddeed60:create

create sequence samqa.invoice_parameters_seq minvalue 1 maxvalue 999999999999999999999999999 increment by 1 start with 137874 cache 20
noorder nocycle nokeep noscale global;

