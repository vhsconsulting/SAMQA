-- liquibase formatted sql
-- changeset SAMQA:1754374150048 stripComments:false logicalFilePath:BASE_RELEASE\samqa\sequences\scheduler_detail_seq.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/sequences/scheduler_detail_seq.sql:null:bec9c6f515284647e6d26794bdcd9adb9e6663e9:create

create sequence samqa.scheduler_detail_seq minvalue 1 maxvalue 999999999999999999999999999 increment by 1 start with 1752788 cache 20
noorder nocycle nokeep noscale global;

