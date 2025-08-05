-- liquibase formatted sql
-- changeset SAMQA:1754374149921 stripComments:false logicalFilePath:BASE_RELEASE\samqa\sequences\sales_assignment_staging_seq.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/sequences/sales_assignment_staging_seq.sql:null:90ccb874746a9872b3d7d830b7847503398d4121:create

create sequence samqa.sales_assignment_staging_seq minvalue 1 maxvalue 9999999999999999999999999999 increment by 1 start with 108011 cache
20 noorder nocycle nokeep noscale global;

