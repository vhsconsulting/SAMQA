-- liquibase formatted sql
-- changeset SAMQA:1754374150081 stripComments:false logicalFilePath:BASE_RELEASE\samqa\sequences\scheduler_seq.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/sequences/scheduler_seq.sql:null:5c2f70c6c32fa598b0765048cb4f7c9a2e4999f3:create

create sequence samqa.scheduler_seq minvalue 1 maxvalue 999999999999999999999999999 increment by 1 start with 193871 cache 20 noorder
nocycle nokeep noscale global;

