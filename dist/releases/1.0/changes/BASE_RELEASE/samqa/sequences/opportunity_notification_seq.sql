-- liquibase formatted sql
-- changeset SAMQA:1754374149599 stripComments:false logicalFilePath:BASE_RELEASE\samqa\sequences\opportunity_notification_seq.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/sequences/opportunity_notification_seq.sql:null:a214ed49e235ba86f294b855c757758d22f602a5:create

create sequence samqa.opportunity_notification_seq minvalue 1 maxvalue 999999999999999999999999999 increment by 1 start with 534306 cache
20 noorder nocycle nokeep noscale global;

