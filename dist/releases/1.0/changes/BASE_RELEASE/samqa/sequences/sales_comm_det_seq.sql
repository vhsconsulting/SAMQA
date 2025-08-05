-- liquibase formatted sql
-- changeset SAMQA:1754374149933 stripComments:false logicalFilePath:BASE_RELEASE\samqa\sequences\sales_comm_det_seq.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/sequences/sales_comm_det_seq.sql:null:829b3795cfb1b292105b08fb8ceb2ebbbb4226b1:create

create sequence samqa.sales_comm_det_seq minvalue 1 maxvalue 9999999999999999999999999999 increment by 1 start with 241812 cache 20 noorder
nocycle nokeep noscale global;

