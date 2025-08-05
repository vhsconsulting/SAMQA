-- liquibase formatted sql
-- changeset SAMQA:1754374149293 stripComments:false logicalFilePath:BASE_RELEASE\samqa\sequences\matrix_prod_order_seq.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/sequences/matrix_prod_order_seq.sql:null:8ff3708c55826d482ef073bae80d958e7b0aa4d3:create

create sequence samqa.matrix_prod_order_seq minvalue 1 maxvalue 999999999999999999999999999 increment by 1 start with 81 cache 20 noorder
nocycle nokeep noscale global;

