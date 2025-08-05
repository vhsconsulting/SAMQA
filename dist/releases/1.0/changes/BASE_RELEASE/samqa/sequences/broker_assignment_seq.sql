-- liquibase formatted sql
-- changeset SAMQA:1754374147702 stripComments:false logicalFilePath:BASE_RELEASE\samqa\sequences\broker_assignment_seq.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/sequences/broker_assignment_seq.sql:null:56daf1a15b6d8d18db5f7eb10ccc24eea0746a14:create

create sequence samqa.broker_assignment_seq minvalue 1 maxvalue 999999999999999999999999999 increment by 1 start with 345662538 cache
20 noorder nocycle nokeep noscale global;

