-- liquibase formatted sql
-- changeset SAMQA:1754374147753 stripComments:false logicalFilePath:BASE_RELEASE\samqa\sequences\calendar_seq.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/sequences/calendar_seq.sql:null:0faf93999133e3d99b8246fb7a3084297068ca77:create

create sequence samqa.calendar_seq minvalue 1 maxvalue 9999999999999999999999999999 increment by 1 start with 55304 cache 20 noorder nocycle
nokeep noscale global;

