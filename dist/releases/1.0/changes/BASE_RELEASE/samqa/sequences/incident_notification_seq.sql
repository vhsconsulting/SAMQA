-- liquibase formatted sql
-- changeset SAMQA:1754374149022 stripComments:false logicalFilePath:BASE_RELEASE\samqa\sequences\incident_notification_seq.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/sequences/incident_notification_seq.sql:null:769bd82303b5918199cfe3fd4a00b8218fd091bc:create

create sequence samqa.incident_notification_seq minvalue 1 maxvalue 999999999999999999999999999 increment by 1 start with 49700 cache
20 noorder nocycle nokeep noscale global;

