-- liquibase formatted sql
-- changeset SAMQA:1754374148166 stripComments:false logicalFilePath:BASE_RELEASE\samqa\sequences\customer_class_gp_seq.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/sequences/customer_class_gp_seq.sql:null:9c29b14a1c47552bb6b32c9136c4d5e1a7368c4e:create

create sequence samqa.customer_class_gp_seq minvalue 1 maxvalue 9999999999999999999999999999 increment by 1 start with 61 cache 20 noorder
nocycle nokeep noscale global;

