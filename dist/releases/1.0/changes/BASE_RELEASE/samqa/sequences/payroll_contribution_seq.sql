-- liquibase formatted sql
-- changeset SAMQA:1754374149685 stripComments:false logicalFilePath:BASE_RELEASE\samqa\sequences\payroll_contribution_seq.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/sequences/payroll_contribution_seq.sql:null:df6bd7bae62a73bdf57b4e4758e5a60cba8546b1:create

create sequence samqa.payroll_contribution_seq minvalue 1 maxvalue 9999999999999999999999999999 increment by 1 start with 773870 cache
20 noorder nocycle nokeep noscale global;

