-- liquibase formatted sql
-- changeset SAMQA:1754374147713 stripComments:false logicalFilePath:BASE_RELEASE\samqa\sequences\broker_authorize_req_seq.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/sequences/broker_authorize_req_seq.sql:null:32a1c4969ca98be69ed7fb5107052f2c1f32ad66:create

create sequence samqa.broker_authorize_req_seq minvalue 1 maxvalue 9999999999999999999999999999 increment by 1 start with 21556 cache
20 noorder nocycle nokeep noscale global;

