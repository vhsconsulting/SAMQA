-- liquibase formatted sql
-- changeset SAMQA:1753779760578 stripComments:false logicalFilePath:BASE_RELEASE\samqa\sequences\api_request_seq.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/sequences/api_request_seq.sql:null:997c3645a879e576d61fe391c665efebcf528ee1:create

create sequence samqa.api_request_seq minvalue 1 maxvalue 9999999999999999999999999999 increment by 1 start with 2325 cache 20 noorder
nocycle nokeep noscale global;

