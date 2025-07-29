-- liquibase formatted sql
-- changeset SAMQA:1753779762551 stripComments:false logicalFilePath:BASE_RELEASE\samqa\sequences\notification_seq.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/sequences/notification_seq.sql:null:1c0b6090b23ec55ebc27e72f41d442c0b1a5780f:create

create sequence samqa.notification_seq minvalue 1 maxvalue 999999999999999999999999999 increment by 1 start with 2472946 cache 20 noorder
nocycle nokeep noscale global;

