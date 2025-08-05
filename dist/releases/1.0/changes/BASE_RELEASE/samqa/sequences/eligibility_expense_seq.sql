-- liquibase formatted sql
-- changeset SAMQA:1754374148411 stripComments:false logicalFilePath:BASE_RELEASE\samqa\sequences\eligibility_expense_seq.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/sequences/eligibility_expense_seq.sql:null:6a2b4f17aeca6a3189c087f042d9c9b5f8bed5c0:create

create sequence samqa.eligibility_expense_seq minvalue 1001 maxvalue 999999999 increment by 1 start with 341841 nocache noorder nocycle
nokeep noscale global;

