-- liquibase formatted sql
-- changeset SAMQA:1754374149483 stripComments:false logicalFilePath:BASE_RELEASE\samqa\sequences\online_enroll_plans_seq.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/sequences/online_enroll_plans_seq.sql:null:1e23d9e6d54f8b81781bde998e277a12e53527e3:create

create sequence samqa.online_enroll_plans_seq minvalue 1 maxvalue 999999999999999999999999999 increment by 1 start with 291871 cache 20
noorder nocycle nokeep noscale global;

