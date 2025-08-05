-- liquibase formatted sql
-- changeset SAMQA:1754374150184 stripComments:false logicalFilePath:BASE_RELEASE\samqa\sequences\tax_forms_seq.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/sequences/tax_forms_seq.sql:null:29eecad646867687567bd9d1092186b34fdfb203:create

create sequence samqa.tax_forms_seq minvalue 1 maxvalue 999999999999999999999999999 increment by 1 start with 7677033 cache 20 noorder
nocycle nokeep noscale global;

