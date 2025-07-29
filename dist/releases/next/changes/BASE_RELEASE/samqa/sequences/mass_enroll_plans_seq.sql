-- liquibase formatted sql
-- changeset SAMQA:1753779762338 stripComments:false logicalFilePath:BASE_RELEASE\samqa\sequences\mass_enroll_plans_seq.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/sequences/mass_enroll_plans_seq.sql:null:212b7e89850d4ba8ad8f274828d31de9ca89ac75:create

create sequence samqa.mass_enroll_plans_seq minvalue 0 maxvalue 999999999999999999999999999 increment by 1 start with 3626672 nocache
noorder nocycle nokeep noscale global;

