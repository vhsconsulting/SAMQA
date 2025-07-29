-- liquibase formatted sql
-- changeset SAMQA:1753779761165 stripComments:false logicalFilePath:BASE_RELEASE\samqa\sequences\contact_role_seq.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/sequences/contact_role_seq.sql:null:dc7733fe95c6b45eb270e9575a5521945b329af3:create

create sequence samqa.contact_role_seq minvalue 1 maxvalue 9999999999999999999999999999 increment by 1 start with 899894 cache 20 noorder
nocycle nokeep noscale global;

