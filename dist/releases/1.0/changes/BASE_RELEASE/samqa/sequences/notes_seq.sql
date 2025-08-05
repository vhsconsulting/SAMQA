-- liquibase formatted sql
-- changeset SAMQA:1754374149432 stripComments:false logicalFilePath:BASE_RELEASE\samqa\sequences\notes_seq.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/sequences/notes_seq.sql:null:c9e52f38e5541a47ccd485a4702cc09584e95152:create

create sequence samqa.notes_seq minvalue 1 maxvalue 999999999999999999999999999 increment by 1 start with 11903539 cache 20 noorder nocycle
nokeep noscale global;

