-- liquibase formatted sql
-- changeset SAMQA:1754374149710 stripComments:false logicalFilePath:BASE_RELEASE\samqa\sequences\plan_emp_contact_seq.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/sequences/plan_emp_contact_seq.sql:null:792baf4db5dc1278c038668871646ffb4d54cabb:create

create sequence samqa.plan_emp_contact_seq minvalue 1001 maxvalue 999999999 increment by 1 start with 382324 nocache noorder nocycle nokeep
noscale global;

