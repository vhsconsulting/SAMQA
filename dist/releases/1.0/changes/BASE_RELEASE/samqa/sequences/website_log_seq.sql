-- liquibase formatted sql
-- changeset SAMQA:1754374150351 stripComments:false logicalFilePath:BASE_RELEASE\samqa\sequences\website_log_seq.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/sequences/website_log_seq.sql:null:88b563f8686fc8189f42f91d09667c8f586149cb:create

create sequence samqa.website_log_seq minvalue 1 maxvalue 9999999999999999999999999999 increment by 1 start with 1587225034 cache 20 noorder
nocycle nokeep noscale global;

