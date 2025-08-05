-- liquibase formatted sql
-- changeset SAMQA:1754374148419 stripComments:false logicalFilePath:BASE_RELEASE\samqa\sequences\eligibility_seq.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/sequences/eligibility_seq.sql:null:34b79ef6b652803e93eb9afa23594a56d0965209:create

create sequence samqa.eligibility_seq minvalue 1 maxvalue 9999999999999999999999999999 increment by 1 start with 84041 cache 20 noorder
nocycle nokeep noscale global;

