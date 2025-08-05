-- liquibase formatted sql
-- changeset SAMQA:1754374148959 stripComments:false logicalFilePath:BASE_RELEASE\samqa\sequences\health_plan_upload_seq.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/sequences/health_plan_upload_seq.sql:null:e52228b4871d122d06a6a911cd7282f854401cb0:create

create sequence samqa.health_plan_upload_seq minvalue 1 maxvalue 9999999999999999999999999999 increment by 1 start with 1661 cache 20
noorder nocycle nokeep noscale global;

