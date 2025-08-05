-- liquibase formatted sql
-- changeset SAMQA:1754374149471 stripComments:false logicalFilePath:BASE_RELEASE\samqa\sequences\notification_seq.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/sequences/notification_seq.sql:null:620b9d5335bfb63c12f826cc1267ae5f91e28bfc:create

create sequence samqa.notification_seq minvalue 1 maxvalue 999999999999999999999999999 increment by 1 start with 2473046 cache 20 noorder
nocycle nokeep noscale global;

