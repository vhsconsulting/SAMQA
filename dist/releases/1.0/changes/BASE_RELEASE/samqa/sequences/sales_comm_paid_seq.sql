-- liquibase formatted sql
-- changeset SAMQA:1754374149946 stripComments:false logicalFilePath:BASE_RELEASE\samqa\sequences\sales_comm_paid_seq.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/sequences/sales_comm_paid_seq.sql:null:740d440d763a198ae1a4a84b345187299833f0d6:create

create sequence samqa.sales_comm_paid_seq minvalue 1 maxvalue 9999999999999999999999999999 increment by 1 start with 17341 cache 20 noorder
nocycle nokeep noscale global;

