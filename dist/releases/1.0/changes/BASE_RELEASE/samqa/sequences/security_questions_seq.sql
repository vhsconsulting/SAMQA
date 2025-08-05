-- liquibase formatted sql
-- changeset SAMQA:1754374150120 stripComments:false logicalFilePath:BASE_RELEASE\samqa\sequences\security_questions_seq.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/sequences/security_questions_seq.sql:null:86da1897fc88a8d7b00271cf79b6c5dea80bd4ed:create

create sequence samqa.security_questions_seq minvalue 1 maxvalue 9999999999999999999999999999 increment by 1 start with 61 cache 20 noorder
nocycle nokeep noscale global;

