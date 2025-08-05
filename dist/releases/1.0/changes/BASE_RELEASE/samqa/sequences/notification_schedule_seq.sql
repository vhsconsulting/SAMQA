-- liquibase formatted sql
-- changeset SAMQA:1754374149458 stripComments:false logicalFilePath:BASE_RELEASE\samqa\sequences\notification_schedule_seq.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/sequences/notification_schedule_seq.sql:null:2f44da1c7cb775f3cee516e2fca10750f49f6605:create

create sequence samqa.notification_schedule_seq minvalue 1 maxvalue 9999999999999999999999999999 increment by 1 start with 1 cache 20
noorder nocycle nokeep noscale global;

