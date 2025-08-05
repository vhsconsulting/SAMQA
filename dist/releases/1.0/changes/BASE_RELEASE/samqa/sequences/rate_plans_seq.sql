-- liquibase formatted sql
-- changeset SAMQA:1754374149811 stripComments:false logicalFilePath:BASE_RELEASE\samqa\sequences\rate_plans_seq.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/sequences/rate_plans_seq.sql:null:4f35dba04b0c61ff83561dea7cec9d703b502a3b:create

create sequence samqa.rate_plans_seq minvalue 1 maxvalue 999999999999999999999999999 increment by 1 start with 122047 cache 20 noorder
nocycle nokeep noscale global;

