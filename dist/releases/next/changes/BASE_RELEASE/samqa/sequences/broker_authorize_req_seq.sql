-- liquibase formatted sql
-- changeset SAMQA:1753779760800 stripComments:false logicalFilePath:BASE_RELEASE\samqa\sequences\broker_authorize_req_seq.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/sequences/broker_authorize_req_seq.sql:null:66327c43d061f67b6aa5ca940923b249a7a7c70f:create

create sequence samqa.broker_authorize_req_seq minvalue 1 maxvalue 9999999999999999999999999999 increment by 1 start with 21496 cache
20 noorder nocycle nokeep noscale global;

