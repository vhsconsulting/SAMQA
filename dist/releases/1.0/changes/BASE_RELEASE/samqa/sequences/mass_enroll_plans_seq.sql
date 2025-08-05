-- liquibase formatted sql
-- changeset SAMQA:1754374149246 stripComments:false logicalFilePath:BASE_RELEASE\samqa\sequences\mass_enroll_plans_seq.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/sequences/mass_enroll_plans_seq.sql:null:3ab1d0f189529bb82f10dc34df90eb29aae808fd:create

create sequence samqa.mass_enroll_plans_seq minvalue 0 maxvalue 999999999999999999999999999 increment by 1 start with 3626685 nocache
noorder nocycle nokeep noscale global;

