-- liquibase formatted sql
-- changeset SAMQA:1753779761172 stripComments:false logicalFilePath:BASE_RELEASE\samqa\sequences\contact_seq.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/sequences/contact_seq.sql:null:b8d42637626c4f5120f1a9ab4620547c7c824106:create

create sequence samqa.contact_seq minvalue 1 maxvalue 9999999999999999999999999999 increment by 1 start with 356438 cache 20 noorder nocycle
nokeep noscale global;

