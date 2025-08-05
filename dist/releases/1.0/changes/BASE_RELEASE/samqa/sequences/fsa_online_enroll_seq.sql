-- liquibase formatted sql
-- changeset SAMQA:1754374148879 stripComments:false logicalFilePath:BASE_RELEASE\samqa\sequences\fsa_online_enroll_seq.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/sequences/fsa_online_enroll_seq.sql:null:09d6b531853fdf449b04954a2e2705e2e6df4901:create

create sequence samqa.fsa_online_enroll_seq minvalue 1001 maxvalue 999999999 increment by 1 start with 359359 nocache noorder nocycle
nokeep noscale global;

