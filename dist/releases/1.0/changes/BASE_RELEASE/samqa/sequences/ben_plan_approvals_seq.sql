-- liquibase formatted sql
-- changeset SAMQA:1754374147615 stripComments:false logicalFilePath:BASE_RELEASE\samqa\sequences\ben_plan_approvals_seq.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/sequences/ben_plan_approvals_seq.sql:null:bad62516a0aefecfedf96dc31996ad015a38aff1:create

create sequence samqa.ben_plan_approvals_seq minvalue 1 maxvalue 9999999999999999999999999999 increment by 1 start with 21669 cache 20
noorder nocycle nokeep noscale global;

