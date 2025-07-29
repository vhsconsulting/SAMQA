-- liquibase formatted sql
-- changeset SAMQA:1753779762876 stripComments:false logicalFilePath:BASE_RELEASE\samqa\sequences\rate_plan_detail_seq.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/sequences/rate_plan_detail_seq.sql:null:49916be5a0a26182ad8dd44d66100573f107e5be:create

create sequence samqa.rate_plan_detail_seq minvalue 1 maxvalue 999999999999999999999999999 increment by 1 start with 342494 cache 20 noorder
nocycle nokeep noscale global;

