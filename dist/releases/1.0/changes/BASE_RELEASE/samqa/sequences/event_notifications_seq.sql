-- liquibase formatted sql
-- changeset SAMQA:1754374148710 stripComments:false logicalFilePath:BASE_RELEASE\samqa\sequences\event_notifications_seq.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/sequences/event_notifications_seq.sql:null:e42ff57e8704cc965613daf7b7ee5d7ddfc28650:create

create sequence samqa.event_notifications_seq minvalue 1 maxvalue 999999999999999999999999999 increment by 1 start with 1112387 cache
20 noorder nocycle nokeep noscale global;

