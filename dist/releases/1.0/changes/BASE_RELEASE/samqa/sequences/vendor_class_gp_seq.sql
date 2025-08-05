-- liquibase formatted sql
-- changeset SAMQA:1754374150286 stripComments:false logicalFilePath:BASE_RELEASE\samqa\sequences\vendor_class_gp_seq.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/sequences/vendor_class_gp_seq.sql:null:9b3f8808cdcc5b40cd3cdd09305ccc9df801aa42:create

create sequence samqa.vendor_class_gp_seq minvalue 1 maxvalue 9999999999999999999999999999 increment by 1 start with 61 cache 20 noorder
nocycle nokeep noscale global;

