-- liquibase formatted sql
-- changeset SAMQA:1754374150158 stripComments:false logicalFilePath:BASE_RELEASE\samqa\sequences\subscriber_leads_seq.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/sequences/subscriber_leads_seq.sql:null:6079e89208f50a2eedcffa53a1c5bbe29661ca95:create

create sequence samqa.subscriber_leads_seq minvalue 1 maxvalue 999999999999999999999999999 increment by 1 start with 181 cache 20 noorder
nocycle nokeep noscale global;

