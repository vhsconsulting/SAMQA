-- liquibase formatted sql
-- changeset SAMQA:1754374147493 stripComments:false logicalFilePath:BASE_RELEASE\samqa\sequences\api_request_seq.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/sequences/api_request_seq.sql:null:54f896805c39c54928ed7528d469398ca413262e:create

create sequence samqa.api_request_seq minvalue 1 maxvalue 9999999999999999999999999999 increment by 1 start with 2345 cache 20 noorder
nocycle nokeep noscale global;

