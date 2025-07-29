-- liquibase formatted sql
-- changeset SAMQA:1753779762974 stripComments:false logicalFilePath:BASE_RELEASE\samqa\sequences\request_log_seq.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/sequences/request_log_seq.sql:null:e9ab97d603c58a47d59f965c96eb691c005f135f:create

create sequence samqa.request_log_seq minvalue 1 maxvalue 9999999999999999999999999999 increment by 1 start with 387 cache 20 noorder
nocycle nokeep noscale global;

