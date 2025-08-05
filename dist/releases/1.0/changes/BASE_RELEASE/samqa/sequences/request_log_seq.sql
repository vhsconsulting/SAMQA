-- liquibase formatted sql
-- changeset SAMQA:1754374149896 stripComments:false logicalFilePath:BASE_RELEASE\samqa\sequences\request_log_seq.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/sequences/request_log_seq.sql:null:5b8c222d9d845810c9e44584703443f8f3d8c448:create

create sequence samqa.request_log_seq minvalue 1 maxvalue 9999999999999999999999999999 increment by 1 start with 467 cache 20 noorder
nocycle nokeep noscale global;

