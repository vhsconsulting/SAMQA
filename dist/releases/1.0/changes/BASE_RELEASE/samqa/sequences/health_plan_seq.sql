-- liquibase formatted sql
-- changeset SAMQA:1754374148943 stripComments:false logicalFilePath:BASE_RELEASE\samqa\sequences\health_plan_seq.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/sequences/health_plan_seq.sql:null:21288a061a73fc454c0c708cc792b4401796848d:create

create sequence samqa.health_plan_seq minvalue 1 maxvalue 999999999999999999999999999 increment by 1 start with 120224 cache 20 noorder
nocycle nokeep noscale global;

