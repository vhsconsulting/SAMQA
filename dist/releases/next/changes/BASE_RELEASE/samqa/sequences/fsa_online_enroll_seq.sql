-- liquibase formatted sql
-- changeset SAMQA:1753779761942 stripComments:false logicalFilePath:BASE_RELEASE\samqa\sequences\fsa_online_enroll_seq.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/sequences/fsa_online_enroll_seq.sql:null:2fae53730a743e7064313eff063492adcd923a05:create

create sequence samqa.fsa_online_enroll_seq minvalue 1001 maxvalue 999999999 increment by 1 start with 359358 nocache noorder nocycle
nokeep noscale global;

