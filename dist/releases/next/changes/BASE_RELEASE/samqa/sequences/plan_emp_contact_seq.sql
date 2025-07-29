-- liquibase formatted sql
-- changeset SAMQA:1753779762788 stripComments:false logicalFilePath:BASE_RELEASE\samqa\sequences\plan_emp_contact_seq.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/sequences/plan_emp_contact_seq.sql:null:9efd3cfd091a9aefedd7e7d30d90e0d676f3b40f:create

create sequence samqa.plan_emp_contact_seq minvalue 1001 maxvalue 999999999 increment by 1 start with 382252 nocache noorder nocycle nokeep
noscale global;

