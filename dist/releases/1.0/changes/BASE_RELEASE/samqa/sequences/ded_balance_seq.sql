-- liquibase formatted sql
-- changeset SAMQA:1754374148202 stripComments:false logicalFilePath:BASE_RELEASE\samqa\sequences\ded_balance_seq.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/sequences/ded_balance_seq.sql:null:d02907ee07514a5257b0a909e37fdfd94aab9695:create

create sequence samqa.ded_balance_seq minvalue 1 maxvalue 999999999999999999999999999 increment by 1 start with 12623 nocache noorder
nocycle nokeep noscale global;

