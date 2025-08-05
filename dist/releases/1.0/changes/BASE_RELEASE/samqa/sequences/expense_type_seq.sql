-- liquibase formatted sql
-- changeset SAMQA:1754374148734 stripComments:false logicalFilePath:BASE_RELEASE\samqa\sequences\expense_type_seq.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/sequences/expense_type_seq.sql:null:6efec0214074520df0abce28df5fce671af3a300:create

create sequence samqa.expense_type_seq minvalue 1 maxvalue 999999999999999999999999999 increment by 1 start with 84 cache 20 noorder nocycle
nokeep noscale global;

