-- liquibase formatted sql
-- changeset SAMQA:1753779762574 stripComments:false logicalFilePath:BASE_RELEASE\samqa\sequences\online_enroll_seq.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/sequences/online_enroll_seq.sql:null:270da9936ca6ad747ddedfff40e96ea6b3a6dfb9:create

create sequence samqa.online_enroll_seq minvalue 1 maxvalue 999999999999999999999999999 increment by 1 start with 1430187 cache 20 noorder
nocycle nokeep noscale global;

