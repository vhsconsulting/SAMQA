-- liquibase formatted sql
-- changeset SAMQA:1754374149799 stripComments:false logicalFilePath:BASE_RELEASE\samqa\sequences\rate_plan_detail_seq.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/sequences/rate_plan_detail_seq.sql:null:3e7e072938ccfc7161e1d914c19cd9fe93ae27c4:create

create sequence samqa.rate_plan_detail_seq minvalue 1 maxvalue 999999999999999999999999999 increment by 1 start with 342614 cache 20 noorder
nocycle nokeep noscale global;

