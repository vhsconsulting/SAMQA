-- liquibase formatted sql
-- changeset SAMQA:1754374148722 stripComments:false logicalFilePath:BASE_RELEASE\samqa\sequences\events_seq.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/sequences/events_seq.sql:null:5cc91572f2f24c01a04ebb0456c93493814a0637:create

create sequence samqa.events_seq minvalue 1 maxvalue 999999999999999999999999999 increment by 1 start with 841 cache 20 noorder nocycle
nokeep noscale global;

