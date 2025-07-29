-- liquibase formatted sql
-- changeset SAMQA:1753779760788 stripComments:false logicalFilePath:BASE_RELEASE\samqa\sequences\broker_assignment_seq.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/sequences/broker_assignment_seq.sql:null:9db31894df5a4eb5c29324d1923aa3a6a49cb0d1:create

create sequence samqa.broker_assignment_seq minvalue 1 maxvalue 999999999999999999999999999 increment by 1 start with 345662458 cache
20 noorder nocycle nokeep noscale global;

