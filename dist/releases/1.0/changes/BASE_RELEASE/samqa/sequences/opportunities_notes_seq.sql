-- liquibase formatted sql
-- changeset SAMQA:1754374149588 stripComments:false logicalFilePath:BASE_RELEASE\samqa\sequences\opportunities_notes_seq.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/sequences/opportunities_notes_seq.sql:null:387aedbe951a7c735e4653379836ab0d98bc2e3f:create

create sequence samqa.opportunities_notes_seq minvalue 1 maxvalue 9999999999999999999999999999 increment by 1 start with 750843 cache
20 noorder nocycle nokeep noscale global;

