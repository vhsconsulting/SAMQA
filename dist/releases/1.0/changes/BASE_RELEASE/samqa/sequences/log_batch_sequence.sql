-- liquibase formatted sql
-- changeset SAMQA:1754374149208 stripComments:false logicalFilePath:BASE_RELEASE\samqa\sequences\log_batch_sequence.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/sequences/log_batch_sequence.sql:null:55f299cbbaaaf4b7bd4a49a3dc7624ac4502fb0d:create

create sequence samqa.log_batch_sequence minvalue 1 maxvalue 9999999999999999999999999999 increment by 1 start with 37377 cache 20 noorder
nocycle nokeep noscale global;

