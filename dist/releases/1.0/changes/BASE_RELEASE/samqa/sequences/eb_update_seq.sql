-- liquibase formatted sql
-- changeset SAMQA:1754374148387 stripComments:false logicalFilePath:BASE_RELEASE\samqa\sequences\eb_update_seq.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/sequences/eb_update_seq.sql:null:a2cf3fee0d8b49538d4eacfb17cd7f3b1c52739f:create

create sequence samqa.eb_update_seq minvalue 1 maxvalue 1000000000000000000000000000 increment by 1 start with 258238 nocache noorder
nocycle nokeep noscale global;

