-- liquibase formatted sql
-- changeset SAMQA:1754374149958 stripComments:false logicalFilePath:BASE_RELEASE\samqa\sequences\sales_comm_rates_seq.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/sequences/sales_comm_rates_seq.sql:null:564338e72c051f3b52d118929ce1afe90e4582c5:create

create sequence samqa.sales_comm_rates_seq minvalue 1 maxvalue 9999999999999999999999999999 increment by 1 start with 221 cache 20 noorder
nocycle nokeep noscale global;

