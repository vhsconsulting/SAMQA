-- liquibase formatted sql
-- changeset SAMQA:1754374148004 stripComments:false logicalFilePath:BASE_RELEASE\samqa\sequences\cobra_interface_error_seq.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/sequences/cobra_interface_error_seq.sql:null:2b52f118d59e1f83e525b08496dd5e5a16316796:create

create sequence samqa.cobra_interface_error_seq minvalue 1 maxvalue 9999999999999999999999999999 increment by 1 start with 11169589 cache
20 noorder nocycle nokeep noscale global;

