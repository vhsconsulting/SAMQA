-- liquibase formatted sql
-- changeset SAMQA:1754374149011 stripComments:false logicalFilePath:BASE_RELEASE\samqa\sequences\incident_history_seq.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/sequences/incident_history_seq.sql:null:c5bf64f2c5d008b2afa691901d8740fe92dd1aec:create

create sequence samqa.incident_history_seq minvalue 1 maxvalue 9999999999999999999999999999 increment by 1 start with 67510 cache 20 noorder
nocycle nokeep noscale global;

