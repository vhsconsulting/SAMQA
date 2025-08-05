-- liquibase formatted sql
-- changeset SAMQA:1754374147426 stripComments:false logicalFilePath:BASE_RELEASE\samqa\sequences\activity_seq.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/sequences/activity_seq.sql:null:705330b9216f8561e2cffd58446aca7754faf532:create

create sequence samqa.activity_seq minvalue 1 maxvalue 9999999999999999999999999999 increment by 1 start with 1481 cache 20 noorder nocycle
nokeep noscale global;

